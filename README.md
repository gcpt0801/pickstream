# 🎲 PickStream

A modern web application for random selection from custom lists. Built with Java 17, deployed on GCP using Infrastructure as Code with complete CI/CD pipeline.

![Java](https://img.shields.io/badge/Java-17-orange?logo=java)
![Maven](https://img.shields.io/badge/Maven-3.6.3-blue?logo=apachemaven)
![Tomcat](https://img.shields.io/badge/Tomcat-9-yellow?logo=apachetomcat)
![GCP](https://img.shields.io/badge/GCP-Compute%20Engine-blue?logo=googlecloud)
![Terraform](https://img.shields.io/badge/Terraform-Latest-purple?logo=terraform)
![Packer](https://img.shields.io/badge/Packer-Latest-blue?logo=packer)

## ✨ Features

- 🎯 Random name selection from customizable lists
- ➕ Add new names dynamically via REST API
- 🎨 Modern gradient UI with responsive design
- 🔒 RESTful JSON API backend
- ☁️ Cloud-native deployment on GCP
- 🚀 Full CI/CD with GitHub Actions
- ✅ Unit testing with JUnit & Mockito
- 📊 Code quality with SonarCloud
- 🛡️ Security scanning with Snyk

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                  GitHub Actions                      │
│  Maven Build → SonarCloud → Snyk → Packer → Terraform│
└─────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────┐
│              Google Cloud Platform                   │
│  ┌──────────────┐    ┌──────────────┐              │
│  │  Compute     │────│  VPC Network │              │
│  │  Instance    │    │  & Firewall  │              │
│  └──────────────┘    └──────────────┘              │
│        ↓                                             │
│  ┌──────────────┐    ┌──────────────┐              │
│  │   Tomcat 9   │    │  Static IP   │              │
│  │  + WAR File  │    │   Address    │              │
│  └──────────────┘    └──────────────┘              │
└─────────────────────────────────────────────────────┘
```

## 🛠️ Technology Stack

### Backend
- **Java**: 17 (LTS)
- **Servlet API**: 4.0.1
- **Gson**: 2.10.1 (JSON processing)
- **Build Tool**: Apache Maven 3.6.3

### Infrastructure
- **Cloud Provider**: Google Cloud Platform
- **VM OS**: Ubuntu 22.04 LTS
- **Web Server**: Apache Tomcat 9.0.58
- **IaC**: Terraform (latest)
- **Image Builder**: Packer (latest)

### CI/CD & Quality
- **CI/CD**: GitHub Actions
- **Code Quality**: SonarCloud
- **Security**: Snyk
- **Testing**: JUnit 4.13.2, Mockito 3.12.4
- **State Management**: GCS Backend

## 📋 Prerequisites

### Local Development
- Java 17 (JDK)
- Apache Maven 3.6+
- Git

### Cloud Deployment
- Google Cloud Platform account
- GCP Project with billing enabled
- Service Account with appropriate permissions

### CI/CD Tools
- GitHub account
- SonarCloud account (https://sonarcloud.io)
- Snyk account (https://snyk.io) - optional

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/gcpt0801/pickstream.git
cd pickstream
```

### 2. Local Development

#### Build the Application
```bash
mvn clean package
```

#### Run Tests
```bash
mvn test
```

#### Run Locally (requires Tomcat)
```bash
# Deploy target/pickstream.war to your local Tomcat webapps/
# Access at http://localhost:8080/pickstream
```

### 3. Cloud Deployment Setup

#### A. Google Cloud Platform Setup

1. **Create GCP Project**
   ```bash
   gcloud projects create YOUR_PROJECT_ID
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Enable Required APIs**
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable storage-api.googleapis.com
   ```

3. **Create Service Account**
   ```bash
   gcloud iam service-accounts create pickstream-deployer \
     --display-name="PickStream Deployer"
   
   gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
     --member="serviceAccount:pickstream-deployer@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/compute.admin"
   
   gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
     --member="serviceAccount:pickstream-deployer@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/iam.serviceAccountUser"
   ```

4. **Generate Service Account Key**
   ```bash
   gcloud iam service-accounts keys create key.json \
     --iam-account=pickstream-deployer@YOUR_PROJECT_ID.iam.gserviceaccount.com
   ```

5. **Create GCS Bucket for Terraform State**
   ```bash
   gsutil mb -p YOUR_PROJECT_ID gs://YOUR-BUCKET-NAME
   ```

#### B. SonarCloud Setup

1. **Sign Up**: https://sonarcloud.io
2. **Connect GitHub**: Authorize SonarCloud to access your repository
3. **Create Organization**: Use your GitHub username (e.g., `gcpt0801`)
4. **Generate Token**: 
   - Go to **Account → Security → Generate Token**
   - Copy the token

#### C. Snyk Setup (Optional)

1. **Sign Up**: https://snyk.io
2. **Connect GitHub**: Authorize Snyk
3. **Get API Token**:
   - Go to **Account Settings → General → API Token**
   - Copy the token

#### D. GitHub Secrets Configuration

Add the following secrets in your GitHub repository:  
**Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `GCP_SA_KEY` | GCP Service Account JSON | Contents of `key.json` file |
| `SONAR_TOKEN` | SonarCloud API Token | From SonarCloud Account → Security |
| `SNYK_TOKEN` | Snyk API Token | From Snyk Account Settings (optional) |

#### E. Update Configuration Files

1. **Update `terraform/terraform.tfvars`**:
   ```hcl
   project_id    = "YOUR_PROJECT_ID"
   region        = "us-central1"
   zone          = "us-central1-a"
   instance_name = "pickstream-instance"
   machine_type  = "e2-medium"
   ```

2. **Update `terraform/backend.tf`**:
   ```hcl
   terraform {
     backend "gcs" {
       bucket = "YOUR-BUCKET-NAME"
       prefix = "pickstream/terraform/state"
     }
   }
   ```

3. **Update `packer/variables.pkrvars.hcl`**:
   ```hcl
   project_id = "YOUR_PROJECT_ID"
   zone       = "us-central1-a"
   ```

4. **Commit and Push Changes**:
   ```bash
   git add terraform/terraform.tfvars terraform/backend.tf packer/variables.pkrvars.hcl
   git commit -m "Configure for deployment"
   git push
   ```

### 4. Deploy to GCP

1. **Go to GitHub Actions**: https://github.com/gcpt0801/pickstream/actions
2. **Select**: "Build and Deploy to GCP"
3. **Click**: "Run workflow"
4. **Select**: Production environment
5. **Run workflow**

The pipeline will:
- ✅ Build WAR file with Maven
- ✅ Run unit tests
- ✅ Analyze code with SonarCloud
- ✅ Scan for vulnerabilities with Snyk
- ✅ Create VM image with Packer
- ✅ Deploy infrastructure with Terraform

### 5. Access Your Application

After successful deployment, the workflow will output:
```
🌐 Application URL: http://EXTERNAL_IP:8080/pickstream
📍 External IP: EXTERNAL_IP
```

## 🎮 Usage

### Web Interface
1. Open `http://EXTERNAL_IP:8080/pickstream` in browser
2. Click **"Get Random Name"** to select a random name
3. Enter a name and click **"Add Name"** to add to the list

### REST API

#### Get Random Name
```bash
curl http://EXTERNAL_IP:8080/pickstream/api/random-name
```

**Response**:
```json
{
  "name": "Alice Johnson"
}
```

#### Add New Name
```bash
curl -X POST http://EXTERNAL_IP:8080/pickstream/api/random-name \
  -d "name=John Doe"
```

**Response**:
```json
{
  "success": true,
  "message": "Name added successfully"
}
```

## 🔧 Development

### Project Structure
```
pickstream/
├── src/
│   ├── main/
│   │   ├── java/com/example/webapp/
│   │   │   └── RandomNameServlet.java      # Backend servlet
│   │   └── webapp/
│   │       └── index.html                   # Frontend UI
│   └── test/
│       └── java/com/example/webapp/
│           └── RandomNameServletTest.java   # Unit tests
├── packer/
│   ├── image.pkr.hcl                        # Packer configuration
│   └── variables.pkrvars.hcl                # Packer variables
├── terraform/
│   ├── backend.tf                           # Terraform backend
│   ├── compute.tf                           # GCP resources
│   ├── outputs.tf                           # Output values
│   ├── variables.tf                         # Variable definitions
│   └── terraform.tfvars                     # Variable values
├── .github/workflows/
│   ├── deploy-gcp.yml                       # Main deployment pipeline
│   ├── build.yml                            # Build & test only
│   ├── destroy.yml                          # Infrastructure cleanup
│   ├── pr-checks.yml                        # PR validation
│   └── cleanup.yml                          # Image cleanup
└── pom.xml                                  # Maven configuration
```

### Running Tests Locally
```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=RandomNameServletTest

# Run with coverage
mvn clean test jacoco:report
```

### Code Quality Checks
```bash
# Run SonarCloud analysis locally (requires SONAR_TOKEN)
mvn sonar:sonar \
  -Dsonar.projectKey=gcpt0801_pickstream \
  -Dsonar.organization=gcpt0801 \
  -Dsonar.host.url=https://sonarcloud.io \
  -Dsonar.login=$SONAR_TOKEN
```

### Building Locally
```bash
# Clean build
mvn clean package

# Skip tests
mvn clean package -DskipTests

# Build with specific profile
mvn clean package -P production
```

## 🔄 CI/CD Workflows

### 1. Build and Deploy to GCP
**Trigger**: Manual (workflow_dispatch)  
**Purpose**: Complete deployment pipeline

**Stages**:
1. Maven Build & Test
2. SonarCloud Analysis
3. Snyk Security Scan
4. Packer Image Build
5. Terraform Destroy (existing resources)
6. Terraform Apply (new deployment)

### 2. Build and Test
**Trigger**: Manual  
**Purpose**: Quick validation without deployment

### 3. Destroy GCP Infrastructure
**Trigger**: Manual (requires typing "destroy")  
**Purpose**: Clean up all cloud resources

### 4. PR Checks
**Trigger**: Manual  
**Purpose**: Validate pull requests

### 5. Cleanup
**Trigger**: Manual  
**Purpose**: Delete old Packer images

## 🗑️ Cleanup

### Destroy All Resources
1. Go to: https://github.com/gcpt0801/pickstream/actions
2. Select: "Destroy GCP Infrastructure"
3. Click: "Run workflow"
4. Type: `destroy` in confirmation field
5. Run workflow

This will remove:
- Compute Instance
- Static IP Address
- Firewall Rules
- VPC Network

**Note**: Packer images are retained. Delete manually if needed:
```bash
gcloud compute images list --filter="family:pickstream"
gcloud compute images delete IMAGE_NAME --project=YOUR_PROJECT_ID
```

## 📊 Monitoring & Logs

### View Application Logs
```bash
gcloud compute ssh pickstream-instance --zone=us-central1-a
sudo journalctl -u tomcat9 -f
```

### Check Tomcat Status
```bash
sudo systemctl status tomcat9
```

### View SonarCloud Results
https://sonarcloud.io/project/overview?id=gcpt0801_pickstream

### View Snyk Results
https://app.snyk.io

## 🐛 Troubleshooting

### Application Not Accessible
```bash
# Check if instance is running
gcloud compute instances list

# Check firewall rules
gcloud compute firewall-rules list

# SSH into instance and check Tomcat
gcloud compute ssh pickstream-instance --zone=us-central1-a
sudo systemctl status tomcat9
sudo journalctl -u tomcat9 -n 50
```

### Tomcat Not Starting
```bash
# Check JAVA_HOME
echo $JAVA_HOME

# Check Tomcat logs
sudo cat /var/log/tomcat9/catalina.out

# Verify WAR deployment
ls -la /var/lib/tomcat9/webapps/
```

### Build Failures
```bash
# Verify Java version
java -version

# Clean Maven cache
mvn dependency:purge-local-repository

# Rebuild
mvn clean install -U
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 🔗 Links

- **Repository**: https://github.com/gcpt0801/pickstream
- **SonarCloud**: https://sonarcloud.io/project/overview?id=gcpt0801_pickstream
- **GitHub Actions**: https://github.com/gcpt0801/pickstream/actions

## 👤 Author

Ramesh Vellanki [ https://www.linkedin.com/in/ramesh-vellanki-b12760151/ ]
- GitHub: [@gcpt0801](https://github.com/gcpt0801)

## 🙏 Acknowledgments

- Java Servlet API
- Google Cloud Platform
- HashiCorp (Terraform & Packer)
- SonarCloud
- Snyk
- GitHub Actions

---

**Built with ❤️ using Java, GCP, and Infrastructure as Code**
