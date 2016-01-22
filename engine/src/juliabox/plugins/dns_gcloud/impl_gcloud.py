__author__ = 'Nishanth'


from juliabox.cloud import JBPluginCloud
from juliabox.jbox_util import JBoxCfg
from googleapiclient.discovery import build
from oauth2client.client import GoogleCredentials


class JBoxGCloudDNS(JBPluginCloud):
    provides = [JBPluginCloud.JBP_DNS, JBPluginCloud.JBP_DNS_GCLOUD]

    PROJECT = None
    ZONE = None
    CONN = None

    @staticmethod
    def configure():
        cloud_host = JBoxCfg.get('cloud_host')
        JBoxGCloudDNS.PROJECT = cloud_host['project'] # project name in google dns
        JBoxGCloudDNS.ZONE = cloud_host['zone'] # zone name in google dns

    @staticmethod
    def domain():
        if JBoxGCloudDNS.PROJECT is None:
            JBoxGCloudDNS.configure()
        return JBoxGCloudDNS.PROJECT

    @staticmethod
    def connect():
        if JBoxGCloudDNS.CONN is None:
            JBoxGCloudDNS.configure()
            # should run `gcloud auth login` to have this default
            creds = GoogleCredentials.get_application_default()
            JBoxGCloudDNS.CONN = build('dns', 'v1', credentials=creds)
        return JBoxGCloudDNS.CONN

    @staticmethod
    def add_cname(name, value):
        JBoxGCloudDNS.connect().changes().create(
            project=JBoxGCloudDNS.PROJECT, managedZone=JBoxGCloudDNS.ZONE,
            body={"kind": "dns#change",
                  "additions": [
                      {"rrdatas": [value],
                       "kind": "dns#resourceRecordSet",
                       "type": "CNAME",
                       "name": name,
                       "ttl": 300}    ] }).execute()

    @staticmethod
    def delete_cname(name):
        resp = JBoxGCloudDNS.connect().resourceRecordSets().list(
            project=JBoxGCloudDNS.PROJECT, managedZone=JBoxGCloudDNS.ZONE,
            name=name, type="CNAME").execute()
        if len(resp["rrsets"]) == 0:
            JBoxGCloudDNS.log_debug("No prior dns registration found for %s", name)
        else:
            cname = resp["rrsets"][0]["rrdatas"][0]
            ttl = resp["ttl"]
            JBoxGCloudDNS.connect().changes().create(
                project=JBoxGCloudDNS.PROJECT, managedZone=JBoxGCloudDNS.ZONE,
                body={"kind": "dns#change",
                      "deletions": [
                          {"rrdatas": [str(cname)],
                           "kind": "dns#resourceRecordSet",
                           "type": "CNAME",
                           "name": name,
                           "ttl": ttl}    ] }).execute()
            JBoxGCloudDNS.log_warn("Prior dns registration was found for %s", name)
