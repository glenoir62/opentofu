package test // Définit le nom du package. Les fichiers dans le même répertoire avec le même nom de package font partie du même package.

import (
	// Importation des packages nécessaires pour le test.

	"fmt"      // Package pour la manipulation de chaînes de caractères formatées (similaire à printf).
	"io"       // Package pour la lecture et l'écriture de flux de données (comme les réponses HTTP).
	"net/http" // Package standard pour effectuer des requêtes HTTP.
	"strings"  // Package pour tester si une chaîne est incluse dans une autre.
	"testing"  // Package de base pour écrire des tests automatisés en Go.
	"time"     // Package pour la manipulation du temps (durées, délais, etc.).

	// aws est un module de Terratest pour interagir avec les services AWS.
	// Il fournit des fonctions pour récupérer des informations sur les ressources AWS, comme les tags d'une instance EC2.
	aws "github.com/gruntwork-io/terratest/modules/aws"

	// Le module terraform de Terratest permet d'exécuter des commandes Terraform (init, apply, output, destroy).
	"github.com/gruntwork-io/terratest/modules/terraform"

	// retry est un module utilitaire pour exécuter du code avec des tentatives multiples (retries).
	"github.com/gruntwork-io/terratest/modules/retry"

	// Le package testify/assert fournit des fonctions d'assertion pour vérifier les résultats des tests (ex: assert.Equal).
	"github.com/stretchr/testify/assert"
)

// TestTerraformInstanceWebModule est le nom de notre fonction de test.
// En Go, les fonctions de test doivent commencer par "Test", suivi d'un nom descriptif.
// Elles prennent un argument `t *testing.T`, qui est un "hook" dans le framework de test de Go.
func TestTerraformInstanceWebModule(t *testing.T) {
	// t.Parallel() permet à ce test de s'exécuter en parallèle avec d'autres tests marqués de la même manière.
	t.Parallel()

	// terraformOptions configure les options pour l'exécution de Terraform.
	terraformOptions := &terraform.Options{
		// TerraformDir spécifie le chemin vers le répertoire contenant votre code Terraform (fichiers .tf).
		TerraformDir: "../",
        // ← IMPORTANT : Utiliser tofu au lieu de terraform
        TerraformBinary: "tofu",
		// Vars est une map (dictionnaire) de variables à passer à votre configuration Terraform.
		Vars: map[string]interface{}{
			"project_name": "TerratestDemo", // Définit la variable Terraform 'project_name' à "TerratestDemo".
		},

		// EnvVars permet de définir des variables d'environnement pour Terraform.
		// Utile pour spécifier un profil AWS différent.
		EnvVars: map[string]string{
			"AWS_PROFILE": "projet1-sso",
		},
        // Pour éviter les problèmes de backend
        Reconfigure: true,
        NoColor:       true,
	}

	// defer terraform.Destroy s'assure que les ressources Terraform seront détruites à la fin du test.
	defer terraform.Destroy(t, terraformOptions)

	// terraform.InitAndApply initialise et applique la configuration Terraform.
	terraform.InitAndApply(t, terraformOptions)

	// Récupération de l'adresse IP publique de l'instance EC2.
	publicIp := terraform.Output(t, terraformOptions, "web_server_public_ip")

	// Construction de l'URL à tester à partir de l'adresse IP publique.
	url := fmt.Sprintf("http://%s", publicIp)

	// Texte que l'on s'attend à retrouver dans la page HTML servie par NGINX.
	expectedText := "Informations sur cette Instance EC2 (Servi par NGINX)"

	// Nombre de tentatives maximales et délai entre chaque tentative.
	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	// Utilisation du module retry pour exécuter la requête HTTP plusieurs fois jusqu'à succès ou épuisement des tentatives.
	_, err := retry.DoWithRetryE(
		t,
		"vérification HTTP avec body contenant un texte spécifique",
		maxRetries,
		timeBetweenRetries,
		func() (string, error) {
			// Exécution d'une requête GET via le package standard net/http.
			resp, err := http.Get(url)
			if err != nil {
				// Retourne une erreur si la requête échoue (erreur réseau, DNS, etc.).
				return "", fmt.Errorf("échec HTTP GET : %w", err)
			}
			defer resp.Body.Close()

			// Vérifie que le code HTTP est bien 200 (OK).
			if resp.StatusCode != 200 {
				return "", fmt.Errorf("code HTTP inattendu : %d", resp.StatusCode)
			}

			// Lecture du corps de la réponse HTTP.
			bodyBytes, err := io.ReadAll(resp.Body)
			if err != nil {
				return "", fmt.Errorf("lecture du body échouée : %w", err)
			}
			body := string(bodyBytes)

			// Vérifie que le body contient bien le texte attendu.
			if !strings.Contains(body, expectedText) {
				return "", fmt.Errorf("contenu incorrect, texte attendu manquant")
			}

			// Tout est bon, on peut retourner une chaîne de confirmation sans erreur.
			return "réponse correcte", nil
		},
	)

	// Si la fonction retourne une erreur après toutes les tentatives, on échoue ici.
	assert.NoError(t, err)

	// Vérification des tags AWS de l'instance EC2.
	instanceID := terraform.Output(t, terraformOptions, "web_server_instance_id")
	awsRegion := "eu-west-3"

	// Récupère les tags appliqués à l'instance EC2.
	instanceTags := aws.GetTagsForEc2Instance(t, awsRegion, instanceID)

	// Vérifie que les tags sont bien ceux attendus.
	assert.Equal(t, "TerratestDemo", instanceTags["Project"], "le tag Project ne correspond pas")
	assert.Equal(t, "dev", instanceTags["Environment"], "le tag Environment ne correspond pas")
}