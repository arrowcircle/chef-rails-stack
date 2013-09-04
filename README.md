# chef-rails-stack

## Configuration

    {
  	  "json_class": "Chef::Role",
      "name": "sample_role",
      "description": "Rails application server testapp",
      "run_list": ["recipe[rails-stack]"],
      "default_attributes": {
        "nginx": {
          "version": "1.4.1",
          "init_style": "init"
        },
        "users": [
         { 
           "user": "username",
           "authorized_keys": ["YOUR_SSH_KEY"],
           "known_hosts": ["YOUR_KNOWN_HOST"]
         }
        ],
        "apps":
          [
            {
              "name": "YOUR_APP_NAME",
              "user": "username",
              "ruby_version": "2.0.0-p247",
              "domain_names": ["DOMAIN_NAME", "DOMAIN_NAME1"],
              "app_server": {
                "type": "unicorn",
                "timeout": "50",
                "workers": "2"
              },
              "database": {
                "dbname": "DBNAME_production",
                "server": true,
                "type": "postgresql",
                "username": "DB_USERNAME",
                "password": "DB_PASSWORD",
                "host": "localhost"
              }
            }
          ]
      }
    }

This cookbook is the part of `chef-rails-suite` pack.

For more info follow https://github.com/arrowcircle/chef-rails-suite