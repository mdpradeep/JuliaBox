import json
import base64

import tornado.escape

from cloud.aws import CloudHost
from utils.jbox_crypto import encrypt, decrypt
from handlers.handler_base import JBoxHandler


class CorsHandler(JBoxHandler):
    def get(self):
        args = self.get_argument('m', default=None)

        if args is not None:
            args = json.loads(decrypt(base64.b64decode(args), self.config(key='sesskey')))

        if args is not None:
            self.log_debug("setting cookies")
            for cname in ['sessname', 'hostshell', 'hostupload', 'hostipnb', 'sign', 'juliabox']:
                self.set_cookie(cname, args[cname])
            self.set_status(status_code=204)
            self.finish()
        else:
            args = dict()
            for cname in ['sessname', 'hostshell', 'hostupload', 'hostipnb', 'sign', 'juliabox']:
                args[cname] = self.get_cookie(cname)
            args = tornado.escape.url_escape(base64.b64encode(encrypt(json.dumps(args), self.config(key='sesskey'))))
            url = "//" + CloudHost.notebook_websocket_hostname() + "/cors/?m=" + args
            self.log_debug("redirecting to " + url)
            self.redirect(url)
