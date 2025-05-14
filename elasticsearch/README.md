Role Name
=========

An Ansible role to install and configure Elasticsearch on RedHat and Debian‑based distributions.

Requirements
------------

- Ansible ≥ 2.9  
- `become` privileges on target hosts  
- YUM or APT package manager  

Role Variables
--------------

Defined in `vars/main.yml` (override as needed in your playbook or host/group vars):

| Variable                      | Default                                    | Description                                               |
|-------------------------------|--------------------------------------------|-----------------------------------------------------------|
| `es_version`                  | `"8.x"`                                    | The version of Elasticsearch to install.                  |
| `es_cluster_name`             | `"my-es-cluster"`                          | Name of the Elasticsearch cluster.                        |
| `enable_security`             | `"false"`                                  | Whether to enable xpack security on the cluster           |

Dependencies
------------

None. The role will configure the Elastic repository and install Java as needed.

Example Playbook
----------------

```yaml
- hosts: elasticsearch_servers
  become: true
  roles:
    - ansible-elasticsearch-role
```

License
-------

BSD

Author Information
------------------

Dor Attar
