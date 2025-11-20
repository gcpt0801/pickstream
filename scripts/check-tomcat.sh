# Script to start Tomcat on the GCP instance

# You can run this in GCP Cloud Shell or after installing gcloud CLI

# Check instance status
gcloud compute instances describe pickstream-instance --zone=us-central1-a --format="value(status)"

# SSH and start Tomcat
gcloud compute ssh pickstream-instance --zone=us-central1-a --command="sudo systemctl start tomcat9 && sudo systemctl status tomcat9"

# Check if port 8080 is listening
gcloud compute ssh pickstream-instance --zone=us-central1-a --command="sudo netstat -tuln | grep 8080"

# View Tomcat logs
gcloud compute ssh pickstream-instance --zone=us-central1-a --command="sudo tail -20 /var/log/tomcat9/catalina.out"
