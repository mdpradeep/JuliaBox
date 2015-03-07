var JuliaBox = (function($, _, undefined){
	var _msg_body = null;
	var _msg_div = null;
	var _gauth = null;
	var _locked = 0;
	var _ping_fails = 0;
	var _max_ping_fails = 4;
	var _loggedout = false;
	
	var self = {
	    send_keep_alive: function() {
	    	if((_ping_fails > _max_ping_fails) || _loggedout) return;
	        $.ajax({
	        	url: '/ping/',
	        	type: 'GET',
	        	timeout: 5000,
	        	success: function(res) {
	        		_ping_fails = 0;
	        	},
	        	error: function(res) {
	        		_ping_fails += 1;
	        		if (_ping_fails > _max_ping_fails) {
	        			self.inform_logged_out(true);
	        		}
	        	}
	        });
	    },
	    
	    comm: function(url, type, data, success, error) {
	    	self.lock_activity();
	    	$.ajax({
	    		url: url,
	    		type: type,
	    		data: data,
	    		success: function(res) {
	    			self.unlock_activity();
	    			success(res);
	    		},
	    		error: function(res) {
	    			self.unlock_activity();
	    			error(res);
	    		}
	    	});
	    },

	    show_ssh_key: function() {
	    	s = function(sshkey){ bootbox.alert('<pre>' + sshkey.data + '</pre>'); };
	    	f = function() { bootbox.alert("Oops. Unexpected error while retrieving the ssh key.<br/><br/>Please try again later."); };
	    	self.comm('/hostupload/sshkey', 'GET', null, s, f);
	    },

	    switch_julia_image: function(disp_curr, disp_switch) {
	    	s = function(img){
	    	    if(img.code == 0) {
	    	        self.set_julia_image_type(disp_curr, disp_switch, img.data);
	    	        bootbox.alert('Your Julia image has been changed and will be effective the next time you log in.');
	    	    }
	    	    else {
	    	        bootbox.alert("Oops. Unexpected error while switching Julia image.<br/><br/>Please try again later.");
	    	    }
	    	};
	    	f = function() { bootbox.alert("Oops. Unexpected error while switching Julia image.<br/><br/>Please try again later."); };
	    	self.comm('/hostadmin/', 'GET', {'switch_julia_img': true}, s, f);
	    },

	    set_julia_image_type: function(disp_curr, disp_switch, curr_img_type) {
	        if(0 == curr_img_type) {
	            disp_curr.html("standard");
	            disp_switch.html("precompiled packages");
	        }
	        else {
	            disp_switch.html("standard");
	            disp_curr.html("precompiled packages");
	        }
	    },

        _json_to_table: function(o) {
            resp = '<table class="table">';
            for(n in o) {
                resp += '<tr><td>';
                resp += '<b>' + n + '</b>';
                resp += '</td><td>';
                v = o[n];
                if(v instanceof Array) {
                    resp += JSON.stringify(v, [","], " ");
                }
                else if(v && (typeof v === "object")) {
                    resp += self._json_to_table(v);
                }
                else {
                    resp += v;
                }
                resp += '</td></tr>';
            }
            resp += '</table>';
            return resp;
        },

        show_config: function() {
	    	s = function(cfg){
	    	    if(cfg.code == 0) {
	    	        bootbox.dialog({
	    	            message: self._json_to_table(cfg.data),
	    	            title: "Config"
	    	        }).find("div.modal-dialog").addClass("bootbox90");
	    	    }
	    	    else bootbox.alert('<pre>' + cfg.data + '</pre>');
	    	};
	    	f = function() { bootbox.alert("Oops. Unexpected error while retrieving config.<br/><br/>Please try again later."); };
	    	self.comm('/hostadmin/', 'GET', {'show_cfg': true}, s, f);
        },

        _gen_api: function(uri, mode, params, title, desc, s, f) {
            if(!s) {
                s = function(status){
                    if(status.code == 0) {
                        bootbox.dialog({
                            message: self._json_to_table(status.data),
                            title: title
                        }).find("div.modal-dialog").addClass("bootbox70");
                    }
                    else {
                        bootbox.alert('<pre>' + status.data + '</pre>');
                    }
                };
            }
            if(!f) {
	    	    f = function() { bootbox.alert("Oops. Unexpected error while " + desc + ".<br/><br/>Please try again later."); };
            };
            self.comm(uri, 'POST', {
                'mode': mode,
                'params': JSON.stringify(params)
            },
            s, f);
        },

        hw_check: function(course, problemset, question, answer, record, s, f) {
            mode = record ? "submit" : "check";
            params = {'course': course,
                      'problemset': problemset,
                      'question': question,
                      'answer': answer
                     }
            self._gen_api('/hw/', mode, params, 'Evaluation', 'verifying answer', s, f);
        },

        hw_myreport: function(course, problemset, questions, s, f) {
            self.hw_report_base("myreport", course, problemset, questions, s, f);
        },

        hw_report: function(course, problemset, questions, s, f) {
            self.hw_report_base("report", course, problemset, questions, s, f);
        },

        hw_report_base: function(apiname, course, problemset, questions, s, f) {
            params = {
                'course': course,
                'problemset': problemset
            }
            if(questions) {
                params['questions'] = questions;
            }

            self._gen_api('/hw/', apiname, params, 'Evaluations', 'retrieving evaluations', s, f);
        },

        hw_metadata: function(course, problemset, questions, s, f) {
            params = {
                'course': course,
                'problemset': problemset
            }
            if(questions) {
                params['questions'] = questions;
            }
            self._gen_api('/hw/', 'metadata', params, 'Answers', 'retrieving answers', s, f);
        },

        hw_create: function(course, s, f) {
            self._gen_api('/hw/', 'create', course, 'Create Course', 'creating course', s, f);
        },

        api_info: function(api_name, publisher, s, f) {
            params = {}
            if(api_name) params['api_name'] = api_name;
            if(publisher) params['publisher'] = publisher;
            self._gen_api('/jbapi/', 'info', params, 'API Info', 'getting API info', s, f);
        },

        api_create: function(api_spec, s, f) {
            self._gen_api('/jbapi/', 'create', api_spec, 'API Create', 'creating API info', s, f);
        },

        show_stats: function(stat_name, title) {
	    	s = function(stats){
	    	    if(stats.code == 0) {
	    	        bootbox.dialog({
	    	            message: self._json_to_table(stats.data),
	    	            title: title
	    	        }).find("div.modal-dialog").addClass("bootbox70");
	    	    }
	    	    else {
	    	        if(stats.code == 1) bootbox.alert('No data collected yet');
                    else bootbox.alert('<pre>' + stats.data + '</pre>');
	    	    }
	    	};
	    	f = function() { bootbox.alert("Oops. Unexpected error while retrieving stats.<br/><br/>Please try again later."); };
	    	self.comm('/hostadmin/', 'GET', {'stats': stat_name}, s, f);
        },

        show_instance_info: function(stat_name, title) {
	    	s = function(stats){
	    	    if(stats.code == 0) {
	    	        bootbox.dialog({
	                    message: self._json_to_table(stats.data),
	    	            title: title
                    }).find("div.modal-dialog").addClass("bootbox80");
	    	    }
	    	    else {
                    bootbox.alert('<pre>' + stats.data + '</pre>');
	    	    }
	    	};
	    	f = function() { bootbox.alert("Oops. Unexpected error while retrieving stats.<br/><br/>Please try again later."); };
	    	self.comm('/hostadmin/', 'GET', {'instance_info': stat_name}, s, f);
        },

		init_gauth_tok: function(tok) {
			_gauth = tok;
		},
		
		register_jquery_folder_field: function (fld, trig, loc) {
			jqtrig = $('#filesync-frame').contents().find(trig);
			if(_gauth == null) {
				jqtrig.click(function(e){
					self.sync_auth_gdrive();
				});
			}
			else {
				jqfld = $('#filesync-frame').contents().find(fld);
				jqloc = $('#filesync-frame').contents().find(loc);
				jqfld.change(function() {
	        		parts = jqfld.val().split('/');
	        		if(parts.length > 3) {
	        			jqloc.val(parts[2]);
	        		}
	        		else {
	        			jqloc.val('');
	        		}
	            });
				jqfld.prop('readonly', true);
				jqfld.gdrive('set', {
	    			'trigger': jqtrig, 
	    			'header': 'Select a folder to synchronize',
	    			'filter': 'application/vnd.google-apps.folder'
				});				
			}
		},

        showhelp_git: function() {
            bootbox.dialog({
                message: "This is a simple interface to synchronize with GitHub repositories.<br/><br/>" +
                         "Repositories registered here with their HTTPS URLs can only be synchronized from GitHub to JuliaBox. " +
                         "Register the SSH URL to be able to synchronize both ways. " +
                         "You must also <a href='https://help.github.com/articles/generating-ssh-keys/'>add your JuliaBox ssh key to your GitHub account</a> for that. " +
                         "Your JuliaBox ssh key is already generated and can be copied from the settings tab.<br/><br/>" +
                         "Conflicting changes that can not be auto merged are not handled.<br/><br/>",
                title: "Synchronize Git Repositories"
            }).find("div.modal-dialog").addClass("bootbox80");
        },

        showhelp_gdrive: function() {
            bootbox.dialog({
                message: "This is a simple interface to synchronize with Google Drive folders.<br/><br/>" +
                         "Only files that can be downloaded as text or binary formats are supported. " +
                         "If there are conflicting changes between local and remote folders, only the latest version is retained. " +
                         "To delete a file, it must be deleted both from local and remote folders.<br/>",
                title: "Synchronize Google Drive Folders"
            }).find("div.modal-dialog").addClass("bootbox80");
        },

		sync_addgit: function(repo, loc, branch) {
			repo = repo.trim();
			loc = loc.trim();
			branch = branch.trim();
			if(repo.length == 0) {
				return;
			}
			self.inpage_alert('info', 'Adding repository...');
			s = function(res) {
				$('#filesync-frame').attr('src', '/hostupload/sync');
				if(res.code == 0) {
					self.inpage_alert('success', 'Repository added successfully');
				}
				else if(res.code == 1) {
					self.inpage_alert('warning', 'Repository added successfully. Pushing changes to remote repository not supported with HTTP URLs.');
				}
				else {
					self.inpage_alert('danger', 'Error adding repository');
				}
			};
			f = function() { self.inpage_alert('danger', 'Error adding repository.'); };
    		self.comm('/hostupload/sync', 'POST', {'action': 'addgit', 'repo': repo, 'loc': loc, 'branch': branch}, s, f);
		},

		sync_auth_gdrive: function(fn) {
			if(_gauth == null) {
				self.popup_confirm("You must authorize JuliaBox to access Google Drive. Would you like to do that now?", function(res) {
					if(res) {
						top.location.href = '/hostlaunchipnb/?state=ask_gdrive';
					}
				});
			}
			else {
				fn();
			}
		},

		sync_addgdrive: function(repo, loc) {
			repo = repo.trim();
			loc = loc.trim();
			data = {'action': 'addgdrive', 'repo': repo, 'loc': loc, 'gauth': _gauth};
			if(repo.length == 0) {
				return;
			}
			s = function(res) {
				$('#filesync-frame').attr('src', '/hostupload/sync');
				if(res.code == 0) {
					self.inpage_alert('success', 'Repository added successfully');
				}
				else {
					self.inpage_alert('danger', 'Error adding repository');
				}
			};
			f = function() { self.inpage_alert('danger', 'Error adding repository.'); };
			self.sync_auth_gdrive(function(){
				self.inpage_alert('info', 'Adding repository...');
	    		self.comm('/hostupload/sync', 'POST', data, s, f);
			});
		},

		sync_syncgit: function(repo) {
			self.inpage_alert('info', 'Synchronizing repository...');
			s = function(res) {
				if(res.code == 0) {
					self.inpage_alert('success', 'Repository synchronized successfully');
				}
				else if(res.code == 1) {
					self.inpage_alert('warning', 'Repository synchronized with some conflicts');
				}
				else {
					self.inpage_alert('danger', 'Error synchronizing repository');
				}
			};
			f = function() { self.inpage_alert('danger', 'Error synchronizing repository.'); };
    		self.comm('/hostupload/sync', 'POST', {'action': 'syncgit', 'repo': repo}, s, f);
		},

		sync_syncgdrive: function(repo) {
			data = {'action': 'syncgdrive', 'repo': repo, 'gauth': _gauth};
			s = function(res) {
				if(res.code == 0) {
					self.inpage_alert('success', 'Repository synchronized successfully');
				}
				else {
					self.inpage_alert('danger', 'Error synchronizing repository');
				}
			};
			f = function() { self.inpage_alert('danger', 'Error synchronizing repository.'); };
			self.sync_auth_gdrive(function(){
				self.inpage_alert('info', 'Synchronizing repository...');
	    		self.comm('/hostupload/sync', 'POST', data, s, f);
	   		});
		},

		sync_delgit: function(repo) {
			self.inpage_alert('warning', 'Deleting repository...');
			s = function(res) {
				$('#filesync-frame').attr('src', '/hostupload/sync');
				if(res.code == 0) {
					self.inpage_alert('success', 'Repository deleted successfully');
				}
				else {
					self.inpage_alert('danger', 'Error deleting repository');
				}
			};
			f = function() { self.inpage_alert('danger', 'Error deleting repository.'); };
    		self.comm('/hostupload/sync', 'POST', {'action': 'delgit', 'repo': repo}, s, f);
		},

		sync_delgdrive: function(repo) {
			data = {'action': 'delgdrive', 'repo': repo, 'gauth': _gauth};
			s = function(res) {
				$('#filesync-frame').attr('src', '/hostupload/sync');
				if(res.code == 0) {
					self.inpage_alert('success', 'Repository deleted successfully');
				}
				else {
					self.inpage_alert('danger', 'Error deleting repository');
				}
			};
			f = function() { self.inpage_alert('danger', 'Error deleting repository.'); };
			self.sync_auth_gdrive(function(){
				self.inpage_alert('warning', 'Deleting repository...');
	    		self.comm('/hostupload/sync', 'POST', data, s, f);
	   		});
		},
		
		sync_delgit_confirm: function(repo) {
			self.popup_confirm('Are you sure you want to delete this repository?', function(res) {
				if(res) {
					self.sync_delgit(repo);
				}
			});
	    },
		
		sync_delgdrive_confirm: function(repo) {
			self.popup_confirm('Are you sure you want to delete this repository?', function(res) {
				if(res) {
					self.sync_delgdrive(repo);
				}
			});
	    },
		
		init_inpage_alert: function (msg_body, msg_div) {
			_msg_body = msg_body;
			_msg_div = msg_div;
		},

    	inpage_alert: function (msg_level, msg_body) {
    		if(null == _msg_body) return;
    		
    		_msg_body.html(msg_body);
    		_msg_div.removeClass("alert-success alert-info alert-warning alert-danger");
    		_msg_div.addClass("alert-"+msg_level);
    		_msg_div.show();
    	},
    	
    	hide_inpage_alert: function () {
    		_msg_div.hide();
    	},
    	
    	logout_at_browser: function () {
			for (var it in $.cookie()) {
				if(["sessname", "hostshell", "hostupload", "hostipnb", "sign", "juliabox"].indexOf(it) > -1) {
					$.removeCookie(it);
				}
			}
			top.location.href = '/';
			top.location.reload(true);
    	},

		do_logout: function () {
			s = function(res) {};
			f = function() {};
    		self.comm('/hostadmin/', 'GET', { 'logout' : 'me' }, s, f);
		},

    	logout: function () {
			s = function(res) { self.logout_at_browser(); };
			f = function() { self.logout_at_browser(); };
    		self.popup_confirm('Logout from JuliaBox?', function(res) {
    			if(res) {
    			    self.comm('/hostadmin/', 'GET', { 'logout' : 'me' }, s, f);
    			}
    		});
    	},
    	
    	inform_logged_out: function (pingfail) {
    		if(!_loggedout) {
	    		_loggedout = true;
	    		msg = "Your session has terminated / timed out. Please log in again.";
	    		if(pingfail) {
	    		    msg += "<br/><br/>You may also get logged out if JuliaBox servers are not reachable from your browser <br/>" +
	    		           "or you have too many JuliaBox windows open."
	    		}
	    		else {
	    		    self.do_logout();
	    		}
	    		self.popup_alert(msg, function() { self.logout_at_browser(); });
    		}
    	},

		popup_alert: function(msg, fn) {
			bootbox.alert(msg, fn);
		},
		
		popup_confirm: function(msg, fn) {
			bootbox.confirm(msg, fn);
		},
		
		lock_activity: function() {
			_locked += 1;
			if(_locked == 1) {
				//$("#modal-overlay").show();
				$("#modal-overlay").fadeIn();				
			}
		},
		
		unlock_activity: function() {
			_locked -= 1;
			if(_locked == 0) {
				$("#modal-overlay").hide();
			}
		},

		websocktest: function() {
		    bootbox.dialog({
                message: '<iframe src="/assets/html/wsocktest.html" frameborder="0" width="100%" height="40%"></iframe>',
                title: "Testing WekSocket Connectivity..."
            }).find("div.modal-dialog").addClass("bootbox50");
		}
	};
	
	return self;
})(jQuery, _);

