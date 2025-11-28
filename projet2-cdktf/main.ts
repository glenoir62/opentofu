import { Construct } from "constructs";
import { App, TerraformStack, TerraformOutput } from "cdktf";
import { AwsProvider } from "@cdktf/provider-aws/lib/provider";
import { S3Bucket } from "@cdktf/provider-aws/lib/s3-bucket";
// Importer les constructs pour le provider AWS depuis le répertoire .gen/

class MyDemoStack extends TerraformStack {
    constructor(scope: Construct, id: string) {
        super(scope, id);

        // Définir le provider AWS
        new AwsProvider(this, "MonProviderAWS", {
            region: "eu-west-3",
            profile: "projet1-sso", // Votre profil AWS CLI
        });

        // Exemple : créer un bucket S3
        const monBucket = new S3Bucket(this, "MonPremierBucket", {
            bucket: "mon-premier-bucket-cdktf-unique-xxxx", // REMPLACEZ par un nom globalement unique !
            tags: {
                Name: "MonPremierBucketCDKTF",
                Environment: "DemoCDKTF",
            },
        });

        // Exemple d'output
        new TerraformOutput(this, "NomDuBucket", {
            value: monBucket.bucket,
        });
    }
}

const app = new App();
new MyDemoStack(app, "projet2-cdktf"); // Nom de la stack qui apparaîtra dans cdktf.out

// Synthétiser la configuration Terraform JSON
app.synth();