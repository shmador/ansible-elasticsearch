Role Name
=========

An Ansible role to install and configure Kibana on RedHat and Debian‑based distributions.

Requirements
------------

- Ansible ≥ 2.9  
- `become` privileges on target hosts  
- YUM or APT package manager 

Role Variables
--------------

| Variable                     | Default                       | Description                                          |
|------------------------------|-------------------------------|------------------------------------------------------|
| `kibana_version`             | `"8.9.0"`                     | The version of Kibana to install.                    |
| `elasticsearch_url`          | `"http://localhost:9200"`     | Elasticsearch HTTP endpoint Kibana will connect to.  |
| `kibana_listen_host`         | `"0.0.0.0"`                   | Network interface Kibana binds to.                   |
| `kibana_server_port`         | `5601`                        | TCP port for Kibana HTTP.                            |

Dependencies
------------

None. The role will configure the Elastic repository and install any required packages.

Example Playbook
----------------

```yaml
- hosts: kibana_servers
  become: true
  roles:
    - ansible-kibana-role
```

License
-------

BSD

Author Information
------------------

Dor Attar
