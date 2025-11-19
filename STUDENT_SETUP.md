# Student Setup Guide - PickStream Project

This guide will help you set up and deploy the PickStream application using your own GCP account.

## 📋 Prerequisites

### Required Accounts (All Free Tier Available)
- ✅ **GitHub Account** - [Sign up](https://github.com/signup)
- ✅ **Google Cloud Platform** - [Free $300 credit](https://cloud.google.com/free)
- ✅ **SonarCloud Account** - [Free for public repos](https://sonarcloud.io/)
- ✅ **Snyk Account** - [Free tier available](https://snyk.io/signup)

### Required Tools
- Java 17 (OpenJDK)
- Maven 3.6+
- Git
- Packer (latest)
- Terraform (latest)
- GCloud CLI

---

## 🚀 Step-by-Step Setup

### Step 1: Fork or Clone the Repository

**Option A: Fork (Recommended for learning)**
```bash
# Fork via GitHub UI, then clone your fork
git clone https://github.com/YOUR_USERNAME/pickstream.git
cd pickstream
```

**Option B: Clone directly**
```bash
git clone https://github.com/gcpt0801/pickstream.git
cd pickstream
```

---

### Step 2: Install Required Tools

#### **Windows (PowerShell)**
```powershell
# Install Chocolatey (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install tools
choco install openjdk17 maven git packer terraform gcloudsdk -y

# Verify installations
java -version
mvn -version
packer version
terraform version
gcloud version
```

#### **macOS**
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install openjdk@17 maven git packer terraform google-cloud-sdk

# Link Java
sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk

# Verify installations
java -version
mvn -version
packer version
terraform version
gcloud version
```

#### **Linux (Ubuntu/Debian)**
```bash
# Update packages
sudo apt update

# Install Java 17
sudo apt install openjdk-17-jdk-headless -y

# Install Maven
sudo apt install maven -y

# Install Git
sudo apt install git -y

# Install Packer
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer -y

# Install Terraform
sudo apt install terraform -y

# Install GCloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Verify installations
java -version
mvn -version
packer version
terraform version
gcloud version
```

---

### Step 3: Set Up Google Cloud Platform

#### **3.1 Create GCP Project**
```bash
# Login to GCP
gcloud auth login

# Create new project (choose unique project ID)
export PROJECT_ID="pickstream-student-$(whoami)-$(date +%s)"
gcloud projects create $PROJECT_ID --name="PickStream Student Project"

# Set as active project
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable storage-api.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Set default region and zone
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a
```

#### **3.2 Set Up Billing**
⚠️ **Important**: You must enable billing to use Compute Engine
1. Go to [GCP Console](https://console.cloud.google.com)
2. Select your project
3. Go to **Billing** → Link a billing account
4. Use your $300 free credit

#### **3.3 Create Service Account**
```bash
# Create service account
gcloud iam service-accounts create terraform-sa \
    --display-name="Terraform Service Account"

# Get service account email
export SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:Terraform Service Account" \
    --format="value(email)")

# Grant necessary roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/iam.serviceAccountUser"

# Create and download key
gcloud iam service-accounts keys create ~/gcp-key.json \
    --iam-account=$SA_EMAIL

echo "✅ Service account key saved to ~/gcp-key.json"
echo "⚠️  Keep this file secure and never commit to Git!"
```

#### **3.4 Create GCS Bucket for Terraform State**
```bash
# Create unique bucket name
export BUCKET_NAME="tfstate-$(whoami)-$(date +%s)"

# Create bucket
gcloud storage buckets create gs://$BUCKET_NAME \
    --location=us-central1 \
    --uniform-bucket-level-access

echo "✅ Terraform state bucket created: $BUCKET_NAME"
```

---

### Step 4: Update Configuration Files

#### **4.1 Update `terraform/terraform.tfvars`**
```bash
cd terraform
cat > terraform.tfvars << EOF
project_id = "$PROJECT_ID"
region = "us-central1"
zone = "us-central1-a"
instance_name = "pickstream-instance"
machine_type = "e2-medium"
image_family = "pickstream"
EOF
```

#### **4.2 Update `terraform/backend.tf`**
```bash
cat > backend.tf << EOF
terraform {
  backend "gcs" {
    bucket = "$BUCKET_NAME"
    prefix = "pickstream/terraform/state"
  }
}
EOF
```

#### **4.3 Update `packer/image.pkr.hcl`**
```bash
cd ../packer
# Replace project_id in the file
sed -i "s/project_id     = \".*\"/project_id     = \"$PROJECT_ID\"/" image.pkr.hcl

# For macOS use:
# sed -i '' "s/project_id     = \".*\"/project_id     = \"$PROJECT_ID\"/" image.pkr.hcl
```

---

### Step 5: Set Up SonarCloud (Optional but Recommended)

1. Go to [SonarCloud](https://sonarcloud.io/)
2. Sign in with GitHub
3. Click **+** → **Analyze new project**
4. Import your forked repository
5. Copy your **Organization Key** and **Project Key**
6. Generate a token: **My Account** → **Security** → **Generate Token**

**Save these values:**
- Organization: `your-sonarcloud-org`
- Project Key: `your-username_pickstream`
- Token: (keep secure)

---

### Step 6: Set Up Snyk (Optional but Recommended)

1. Go to [Snyk](https://snyk.io/signup)
2. Sign up/Login with GitHub
3. Go to **Settings** → **General**
4. Copy your **Organization ID**
5. Generate token: **Account Settings** → **API Token** → **Generate**

**Save these values:**
- Snyk Token: (keep secure)

---

### Step 7: Local Build and Test

```bash
# Navigate to project root
cd ..

# Build the application
mvn clean package

# Run tests
mvn test

# Verify WAR file created
ls -la target/pickstream.war
```

---

### Step 8: Build Packer Image

```bash
# Set GCP credentials
export GOOGLE_APPLICATION_CREDENTIALS=~/gcp-key.json

# Navigate to packer directory
cd packer

# Validate Packer template
packer validate image.pkr.hcl

# Build image (takes 5-10 minutes)
packer build image.pkr.hcl

# Verify image created
gcloud compute images list --filter="family:pickstream"
```

---

### Step 9: Deploy Infrastructure with Terraform

```bash
# Navigate to terraform directory
cd ../terraform

# Initialize Terraform
terraform init

# Review execution plan
terraform plan

# Apply infrastructure (creates VM, networking, etc.)
terraform apply

# Get instance IP
terraform output instance_ip
```

---

### Step 10: Access Your Application

```bash
# Get the public IP
INSTANCE_IP=$(terraform output -raw instance_ip)

# Wait 2-3 minutes for Tomcat to start, then access:
echo "Application URL: http://$INSTANCE_IP:8080/pickstream/"
echo "API Endpoint: http://$INSTANCE_IP:8080/pickstream/api/random-name"

# Test the application
curl http://$INSTANCE_IP:8080/pickstream/api/random-name
```

Open in browser: `http://YOUR_INSTANCE_IP:8080/pickstream/`

---

## 🧪 Testing Your Deployment

### Check Tomcat Status
```bash
# SSH into instance
gcloud compute ssh pickstream-instance --zone=us-central1-a

# Check Tomcat
sudo systemctl status tomcat9

# View logs
sudo tail -f /var/lib/tomcat9/logs/catalina.out

# Exit SSH
exit
```

### Test API Endpoints
```bash
# Get random name
curl http://INSTANCE_IP:8080/pickstream/api/random-name

# Add new name (POST)
curl -X POST http://INSTANCE_IP:8080/pickstream/api/random-name \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "name=YourName"

# Verify new name appears
curl http://INSTANCE_IP:8080/pickstream/api/random-name
```

---

## 🧹 Cleanup (Important!)

**To avoid charges, destroy resources when done:**

```bash
cd terraform

# Destroy all infrastructure
terraform destroy -auto-approve

# Delete Packer images
gcloud compute images list --filter="family:pickstream" --format="value(name)" | \
  xargs -I {} gcloud compute images delete {} --quiet

# Delete state bucket (optional)
gcloud storage rm -r gs://$BUCKET_NAME

# Delete service account
gcloud iam service-accounts delete $SA_EMAIL --quiet

# Delete project (removes everything)
gcloud projects delete $PROJECT_ID --quiet
```

---

## 💡 Cost Optimization Tips

1. **Use Free Tier**: e2-micro instances are free (modify `machine_type` in `terraform.tfvars`)
2. **Stop When Not Using**:
   ```bash
   gcloud compute instances stop pickstream-instance --zone=us-central1-a
   ```
3. **Set Budget Alerts**: [GCP Billing](https://console.cloud.google.com/billing)
4. **Delete Resources**: Always run `terraform destroy` when done

---

## 🔧 Common Issues and Solutions

### Issue: "Permission Denied" errors
**Solution**: Ensure service account has correct roles:
```bash
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/compute.admin"
```

### Issue: Packer build fails
**Solution**: 
```bash
# Check credentials
echo $GOOGLE_APPLICATION_CREDENTIALS

# Verify API is enabled
gcloud services enable compute.googleapis.com
```

### Issue: Tomcat not starting
**Solution**:
```bash
# SSH and check logs
gcloud compute ssh pickstream-instance --zone=us-central1-a
sudo journalctl -u tomcat9 -f
```

### Issue: Application not accessible
**Solution**:
```bash
# Check firewall rules
gcloud compute firewall-rules list

# Check instance is running
gcloud compute instances list
```

---

## 📚 Learning Resources

- **Maven**: https://maven.apache.org/guides/getting-started/
- **Packer**: https://developer.hashicorp.com/packer/tutorials
- **Terraform**: https://developer.hashicorp.com/terraform/tutorials
- **GCP Free Tier**: https://cloud.google.com/free/docs/free-cloud-features
- **Java Servlets**: https://docs.oracle.com/javaee/7/tutorial/servlets.htm
- **SonarCloud**: https://docs.sonarcloud.io/
- **Snyk**: https://docs.snyk.io/

---

## 🎯 Project Structure Overview

```
pickstream/
├── src/                          # Java source code
│   ├── main/
│   │   ├── java/                # Servlet backend
│   │   └── webapp/              # HTML frontend
│   └── test/                    # Unit tests
├── packer/                      # VM image templates
│   └── image.pkr.hcl           # Packer configuration
├── terraform/                   # Infrastructure as Code
│   ├── backend.tf              # State management
│   ├── compute.tf              # GCP resources
│   ├── variables.tf            # Variable definitions
│   └── terraform.tfvars        # Your values (update this!)
├── .github/workflows/          # CI/CD pipelines
├── pom.xml                     # Maven build file
├── README.md                   # Project documentation
├── CHEATSHEET.md              # Command reference
└── STUDENT_SETUP.md           # This file
```

---

## ✅ Success Checklist

- [ ] All tools installed and verified
- [ ] GCP project created with billing enabled
- [ ] Service account created with proper roles
- [ ] Configuration files updated with your values
- [ ] Application builds successfully (`mvn clean package`)
- [ ] Packer image builds successfully
- [ ] Terraform applies without errors
- [ ] Application accessible via browser
- [ ] API endpoints responding correctly
- [ ] Understand cleanup process to avoid charges

---

## 🤝 Getting Help

1. **Check the main README.md** for detailed documentation
2. **Review CHEATSHEET.md** for command reference
3. **Check GCP Console** for resource status
4. **View logs** using provided commands
5. **Ask instructor** if stuck

---

## 📝 Assignment Ideas

Your instructor may ask you to:
1. ✏️ Modify the application (add features, change UI)
2. 🧪 Write additional unit tests
3. 🔧 Change infrastructure (different machine types, regions)
4. 🚀 Set up CI/CD with GitHub Actions (your own repo)
5. 📊 Integrate with SonarCloud/Snyk for code quality
6. 🔐 Implement security best practices
7. 📈 Add monitoring and alerting
8. 🌐 Set up custom domain with Cloud DNS

---

**Happy Learning! 🎓**

Remember: Always destroy resources when done to avoid unnecessary charges. The GCP free tier is generous, but persistent resources will consume credits over time.
