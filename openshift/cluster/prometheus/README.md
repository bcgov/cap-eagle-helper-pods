# Extending Prometheus Operator metrics with Custom Grafana instance
As the metering operator puts out simple CSVs, we wanted to explore the idea of extending the prometheus metrics which the metering operator pulls from anyway, to get more customized metrics details for the purposes of billing

As the grafana dashboard included with the prometheus operator doesn't allow for customization, we wanted to deploy our own grafana instance which would connect to the prometheus as a datasource, allow for custom dashboards

As we are running OpenShift 3.11 in IBM Cloud, we can't do this the proper way with the Custom Grafana Operator found here, as it requires Operator Lifecycle Manager (OLM) that came with OpenShift 4.x
https://operatorhub.io/operator/grafana-operator

So instead we ran our own grafana instance off-cluster and connected it to prometheus using the service account oauth token for authorization, for the purposes of proving out the approach and showing the available metrics data should we have a proper on-cluster custom grafana instance available


## Process
1. Either install Grafana on your workstation, or preferably run a docker container with the grafana image
2. Update [prom.yaml](prom.yaml) file with your prometheus route and service account token
3. Copy or volume mount the prom.yaml to conf/provisioning/datasources
4. When grafana starts it'll create the datasource from prom.yaml
5. Once grafana is running, you can import [dashboard.json](dashboard.json) or if you want to get fancy add a yaml to /conf/provisioning/dashboards that points to the dashboard.json file
6. Profit