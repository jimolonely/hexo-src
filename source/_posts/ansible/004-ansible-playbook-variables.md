---
title: ansible-playbook变量
tags:
  - ansible
p: ansible/004-ansible-playbook-variables
date: 2019-01-12 17:11:37
---

虽然存在自动化以使事情更容易重复，但所有系统都不完全相同; 有些可能需要与其他配置略有不同的配置。 在某些情况下，观察到的一个系统的行为或状态可能会影响您配置其他系统的方式。 例如，您可能需要找出系统的IP地址，并将其用作另一个系统上的配置值。

Ansible使用变量来帮助处理系统之间的差异。

要理解变量，您还需要阅读[条件](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html#playbooks-conditionals)和[循环](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html#playbooks-loops)。 像group_by模块和when条件这样的有用的东西也可以用于变量，并帮助管理系统之间的差异。

[ansible-examples github仓库](https://github.com/ansible/ansible-examples)包含许多关于如何在Ansible中使用变量的示例。

# 创建有效的变量名称
在开始使用变量之前，了解哪些是有效的变量名称很重要。

变量名称应为字母，数字和下划线。 变量应始终以字母开头。

`foo_port`是一个很好的变量。 `foo5`也很好。

`foo-port，foo port，foo.port和21`都不是有效的变量名。

YAML还支持将键映射到值的字典。 例如：
```yml
foo:
  field1: one
  field2: two
```
然后，您可以使用括号表示法或点表示法引用字典中的特定字段：
```python
foo['field1']
foo.field1
```
这些都将引用相同的值（“one”）。 但是，如果您选择使用点表示法，请注意某些键可能会导致问题，因为它们会与python词典的属性和方法发生冲突。 如果使用以两个下划线开头和结尾的键（那些是为python中的特殊含义保留的）或者是任何已知的公共属性，则应使用括号表示法而不是点表示法：
```python
add, append, as_integer_ratio, bit_length, capitalize, center, clear, conjugate, copy, count, decode, denominator, difference, difference_update, discard, encode, endswith, expandtabs, extend, find, format, fromhex, fromkeys, get, has_key, hex, imag, index, insert, intersection, intersection_update, isalnum, isalpha, isdecimal, isdigit, isdisjoint, is_integer, islower, isnumeric, isspace, issubset, issuperset, istitle, isupper, items, iteritems, iterkeys, itervalues, join, keys, ljust, lower, lstrip, numerator, partition, pop, popitem, real, remove, replace, reverse, rfind, rindex, rjust, rpartition, rsplit, rstrip, setdefault, sort, split, splitlines, startswith, strip, swapcase, symmetric_difference, symmetric_difference_update, title, translate, union, update, upper, values, viewitems, viewkeys, viewvalues, zfill.
```
# 在inventory中声明变量
通常，您需要为单个主机或inventory中的一组主机设置变量。 例如，波士顿的机器可能都使用'boston.ntp.example.com'作为NTP服务器。 “使用清单”页面提供了有关在清单中设置主机变量和组变量的详细信息。

# 在playbook中定义变量
您可以直接在playbook中定义变量：
```yml
- hosts: webservers
  vars:
    http_port: 80
```
# 在include文件和角色中定义变量
如角色中所述，变量也可以通过include文件包含在playbook中，include文件可能是也可能不是Ansible角色的一部分。 首选角色的使用，因为它提供了一个很好的组织系统。

# 使用Jinja2的变量
一旦定义了变量，就可以在playbook中使用Jinja2模板系统。 这是一个简单的Jinja2模板：
```yml
My amp goes to {{ max_amp_value }}
```
该表达式提供了变量替换的最基本形式。

您可以在playbooks中使用相同的语法。 例如：
```yml
template: src=foo.cfg.j2 dest={{ remote_install_path }}/foo.cfg
```
这里变量定义了文件的位置，该文件的位置可能因系统而异。

在模板内，您可以自动访问主机范围内的所有变量。 实际上它不止于此 - 您还可以读取有关其他主机的变量。 我们将展示如何做到这一点。

```
ansible允许模板中的Jinja2循环和条件，但在playbooks中，我们不使用它们。 Ansible剧本是纯机器可解析的YAML。 这是一个相当重要的功能，因为它意味着可以编码生成文件，或者让其他生态系统工具读取Ansible文件。 不是每个人都需要这个，但它可以解锁可能性。
```
# 使用Jinja2过滤器转换变量
Jinja2过滤器允许您在模板表达式中转换变量的值。 例如，大写过滤器会将传递给它的任何值大写; `to_yaml`和`to_json`过滤器会更改变量值的格式。 Jinja2包含许多内置过滤器，Ansible提供了更多过滤器。

# 嘿等等，一个YAML陷阱
YAML语法要求如果您使用{{foo}}启动一个值，则引用整行，因为它要确保您不是要尝试启动YAML字典。 这在YAML语法文档中有所介绍。

这不起作用：
```yml
- hosts: app_servers
  vars:
      app_path: {{ base_path }}/22
```
这样才行：
```yml
- hosts: app_servers
  vars:
       app_path: "{{ base_path }}/22"
```
# 从系统中发现的变量：Facts
还有其他可以来自变量的地方，但这些是发现的变量类型，不是由用户设置的。

事实是通过与您的远程系统通话而获得的信息。 你可以在ansible_facts变量下找到一个完整的集合，大多数事实也被“注入”作为保留ansible_前缀的顶级变量，但是有些因冲突而被删除。 可以通过INJECT_FACTS_AS_VARS设置禁用此功能。

例如，远程主机的IP地址或操作系统是什么。

要查看可用的信息，请在play中尝试以下操作：
```yml
- debug: var=ansible_facts
```
要查看收集的“原始”信息：
```yml
ansible hostname -m setup
```
这将返回大量可变数据，在Ansible 2.7上可能如下所示：
```json
{
    "ansible_all_ipv4_addresses": [
        "REDACTED IP ADDRESS"
    ],
    "ansible_all_ipv6_addresses": [
        "REDACTED IPV6 ADDRESS"
    ],
    "ansible_apparmor": {
        "status": "disabled"
    },
    "ansible_architecture": "x86_64",
    "ansible_bios_date": "11/28/2013",
    "ansible_bios_version": "4.1.5",
    "ansible_cmdline": {
        "BOOT_IMAGE": "/boot/vmlinuz-3.10.0-862.14.4.el7.x86_64",
        "console": "ttyS0,115200",
        "no_timer_check": true,
        "nofb": true,
        "nomodeset": true,
        "ro": true,
        "root": "LABEL=cloudimg-rootfs",
        "vga": "normal"
    },
    "ansible_date_time": {
        "date": "2018-10-25",
        "day": "25",
        "epoch": "1540469324",
        "hour": "12",
        "iso8601": "2018-10-25T12:08:44Z",
        "iso8601_basic": "20181025T120844109754",
        "iso8601_basic_short": "20181025T120844",
        "iso8601_micro": "2018-10-25T12:08:44.109968Z",
        "minute": "08",
        "month": "10",
        "second": "44",
        "time": "12:08:44",
        "tz": "UTC",
        "tz_offset": "+0000",
        "weekday": "Thursday",
        "weekday_number": "4",
        "weeknumber": "43",
        "year": "2018"
    },
    "ansible_default_ipv4": {
        "address": "REDACTED",
        "alias": "eth0",
        "broadcast": "REDACTED",
        "gateway": "REDACTED",
        "interface": "eth0",
        "macaddress": "REDACTED",
        "mtu": 1500,
        "netmask": "255.255.255.0",
        "network": "REDACTED",
        "type": "ether"
    },
    "ansible_default_ipv6": {},
    "ansible_device_links": {
        "ids": {},
        "labels": {
            "xvda1": [
                "cloudimg-rootfs"
            ],
            "xvdd": [
                "config-2"
            ]
        },
        "masters": {},
        "uuids": {
            "xvda1": [
                "cac81d61-d0f8-4b47-84aa-b48798239164"
            ],
            "xvdd": [
                "2018-10-25-12-05-57-00"
            ]
        }
    },
    "ansible_devices": {
        "xvda": {
            "holders": [],
            "host": "",
            "links": {
                "ids": [],
                "labels": [],
                "masters": [],
                "uuids": []
            },
            "model": null,
            "partitions": {
                "xvda1": {
                    "holders": [],
                    "links": {
                        "ids": [],
                        "labels": [
                            "cloudimg-rootfs"
                        ],
                        "masters": [],
                        "uuids": [
                            "cac81d61-d0f8-4b47-84aa-b48798239164"
                        ]
                    },
                    "sectors": "83883999",
                    "sectorsize": 512,
                    "size": "40.00 GB",
                    "start": "2048",
                    "uuid": "cac81d61-d0f8-4b47-84aa-b48798239164"
                }
            },
            "removable": "0",
            "rotational": "0",
            "sas_address": null,
            "sas_device_handle": null,
            "scheduler_mode": "deadline",
            "sectors": "83886080",
            "sectorsize": "512",
            "size": "40.00 GB",
            "support_discard": "0",
            "vendor": null,
            "virtual": 1
        },
        "xvdd": {
            "holders": [],
            "host": "",
            "links": {
                "ids": [],
                "labels": [
                    "config-2"
                ],
                "masters": [],
                "uuids": [
                    "2018-10-25-12-05-57-00"
                ]
            },
            "model": null,
            "partitions": {},
            "removable": "0",
            "rotational": "0",
            "sas_address": null,
            "sas_device_handle": null,
            "scheduler_mode": "deadline",
            "sectors": "131072",
            "sectorsize": "512",
            "size": "64.00 MB",
            "support_discard": "0",
            "vendor": null,
            "virtual": 1
        },
        "xvde": {
            "holders": [],
            "host": "",
            "links": {
                "ids": [],
                "labels": [],
                "masters": [],
                "uuids": []
            },
            "model": null,
            "partitions": {
                "xvde1": {
                    "holders": [],
                    "links": {
                        "ids": [],
                        "labels": [],
                        "masters": [],
                        "uuids": []
                    },
                    "sectors": "167770112",
                    "sectorsize": 512,
                    "size": "80.00 GB",
                    "start": "2048",
                    "uuid": null
                }
            },
            "removable": "0",
            "rotational": "0",
            "sas_address": null,
            "sas_device_handle": null,
            "scheduler_mode": "deadline",
            "sectors": "167772160",
            "sectorsize": "512",
            "size": "80.00 GB",
            "support_discard": "0",
            "vendor": null,
            "virtual": 1
        }
    },
    "ansible_distribution": "CentOS",
    "ansible_distribution_file_parsed": true,
    "ansible_distribution_file_path": "/etc/redhat-release",
    "ansible_distribution_file_variety": "RedHat",
    "ansible_distribution_major_version": "7",
    "ansible_distribution_release": "Core",
    "ansible_distribution_version": "7.5.1804",
    "ansible_dns": {
        "nameservers": [
            "127.0.0.1"
        ]
    },
    "ansible_domain": "",
    "ansible_effective_group_id": 1000,
    "ansible_effective_user_id": 1000,
    "ansible_env": {
        "HOME": "/home/zuul",
        "LANG": "en_US.UTF-8",
        "LESSOPEN": "||/usr/bin/lesspipe.sh %s",
        "LOGNAME": "zuul",
        "MAIL": "/var/mail/zuul",
        "PATH": "/usr/local/bin:/usr/bin",
        "PWD": "/home/zuul",
        "SELINUX_LEVEL_REQUESTED": "",
        "SELINUX_ROLE_REQUESTED": "",
        "SELINUX_USE_CURRENT_RANGE": "",
        "SHELL": "/bin/bash",
        "SHLVL": "2",
        "SSH_CLIENT": "23.253.245.60 55672 22",
        "SSH_CONNECTION": "23.253.245.60 55672 104.130.127.149 22",
        "USER": "zuul",
        "XDG_RUNTIME_DIR": "/run/user/1000",
        "XDG_SESSION_ID": "1",
        "_": "/usr/bin/python2"
    },
    "ansible_eth0": {
        "active": true,
        "device": "eth0",
        "ipv4": {
            "address": "REDACTED",
            "broadcast": "REDACTED",
            "netmask": "255.255.255.0",
            "network": "REDACTED"
        },
        "ipv6": [
            {
                "address": "REDACTED",
                "prefix": "64",
                "scope": "link"
            }
        ],
        "macaddress": "REDACTED",
        "module": "xen_netfront",
        "mtu": 1500,
        "pciid": "vif-0",
        "promisc": false,
        "type": "ether"
    },
    "ansible_eth1": {
        "active": true,
        "device": "eth1",
        "ipv4": {
            "address": "REDACTED",
            "broadcast": "REDACTED",
            "netmask": "255.255.224.0",
            "network": "REDACTED"
        },
        "ipv6": [
            {
                "address": "REDACTED",
                "prefix": "64",
                "scope": "link"
            }
        ],
        "macaddress": "REDACTED",
        "module": "xen_netfront",
        "mtu": 1500,
        "pciid": "vif-1",
        "promisc": false,
        "type": "ether"
    },
    "ansible_fips": false,
    "ansible_form_factor": "Other",
    "ansible_fqdn": "centos-7-rax-dfw-0003427354",
    "ansible_hostname": "centos-7-rax-dfw-0003427354",
    "ansible_interfaces": [
        "lo",
        "eth1",
        "eth0"
    ],
    "ansible_is_chroot": false,
    "ansible_kernel": "3.10.0-862.14.4.el7.x86_64",
    "ansible_lo": {
        "active": true,
        "device": "lo",
        "ipv4": {
            "address": "127.0.0.1",
            "broadcast": "host",
            "netmask": "255.0.0.0",
            "network": "127.0.0.0"
        },
        "ipv6": [
            {
                "address": "::1",
                "prefix": "128",
                "scope": "host"
            }
        ],
        "mtu": 65536,
        "promisc": false,
        "type": "loopback"
    },
    "ansible_local": {},
    "ansible_lsb": {
        "codename": "Core",
        "description": "CentOS Linux release 7.5.1804 (Core)",
        "id": "CentOS",
        "major_release": "7",
        "release": "7.5.1804"
    },
    "ansible_machine": "x86_64",
    "ansible_machine_id": "2db133253c984c82aef2fafcce6f2bed",
    "ansible_memfree_mb": 7709,
    "ansible_memory_mb": {
        "nocache": {
            "free": 7804,
            "used": 173
        },
        "real": {
            "free": 7709,
            "total": 7977,
            "used": 268
        },
        "swap": {
            "cached": 0,
            "free": 0,
            "total": 0,
            "used": 0
        }
    },
    "ansible_memtotal_mb": 7977,
    "ansible_mounts": [
        {
            "block_available": 7220998,
            "block_size": 4096,
            "block_total": 9817227,
            "block_used": 2596229,
            "device": "/dev/xvda1",
            "fstype": "ext4",
            "inode_available": 10052341,
            "inode_total": 10419200,
            "inode_used": 366859,
            "mount": "/",
            "options": "rw,seclabel,relatime,data=ordered",
            "size_available": 29577207808,
            "size_total": 40211361792,
            "uuid": "cac81d61-d0f8-4b47-84aa-b48798239164"
        },
        {
            "block_available": 0,
            "block_size": 2048,
            "block_total": 252,
            "block_used": 252,
            "device": "/dev/xvdd",
            "fstype": "iso9660",
            "inode_available": 0,
            "inode_total": 0,
            "inode_used": 0,
            "mount": "/mnt/config",
            "options": "ro,relatime,mode=0700",
            "size_available": 0,
            "size_total": 516096,
            "uuid": "2018-10-25-12-05-57-00"
        }
    ],
    "ansible_nodename": "centos-7-rax-dfw-0003427354",
    "ansible_os_family": "RedHat",
    "ansible_pkg_mgr": "yum",
    "ansible_processor": [
        "0",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "1",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "2",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "3",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "4",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "5",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "6",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz",
        "7",
        "GenuineIntel",
        "Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz"
    ],
    "ansible_processor_cores": 8,
    "ansible_processor_count": 8,
    "ansible_processor_threads_per_core": 1,
    "ansible_processor_vcpus": 8,
    "ansible_product_name": "HVM domU",
    "ansible_product_serial": "REDACTED",
    "ansible_product_uuid": "REDACTED",
    "ansible_product_version": "4.1.5",
    "ansible_python": {
        "executable": "/usr/bin/python2",
        "has_sslcontext": true,
        "type": "CPython",
        "version": {
            "major": 2,
            "micro": 5,
            "minor": 7,
            "releaselevel": "final",
            "serial": 0
        },
        "version_info": [
            2,
            7,
            5,
            "final",
            0
        ]
    },
    "ansible_python_version": "2.7.5",
    "ansible_real_group_id": 1000,
    "ansible_real_user_id": 1000,
    "ansible_selinux": {
        "config_mode": "enforcing",
        "mode": "enforcing",
        "policyvers": 31,
        "status": "enabled",
        "type": "targeted"
    },
    "ansible_selinux_python_present": true,
    "ansible_service_mgr": "systemd",
    "ansible_ssh_host_key_ecdsa_public": "REDACTED KEY VALUE",
    "ansible_ssh_host_key_ed25519_public": "REDACTED KEY VALUE",
    "ansible_ssh_host_key_rsa_public": "REDACTED KEY VALUE",
    "ansible_swapfree_mb": 0,
    "ansible_swaptotal_mb": 0,
    "ansible_system": "Linux",
    "ansible_system_capabilities": [
        ""
    ],
    "ansible_system_capabilities_enforced": "True",
    "ansible_system_vendor": "Xen",
    "ansible_uptime_seconds": 151,
    "ansible_user_dir": "/home/zuul",
    "ansible_user_gecos": "",
    "ansible_user_gid": 1000,
    "ansible_user_id": "zuul",
    "ansible_user_shell": "/bin/bash",
    "ansible_user_uid": 1000,
    "ansible_userspace_architecture": "x86_64",
    "ansible_userspace_bits": "64",
    "ansible_virtualization_role": "guest",
    "ansible_virtualization_type": "xen",
    "gather_subset": [
        "all"
    ],
    "module_setup": true
}
```
在上面，第一个磁盘的模型可以在模板或剧本中引用为：
```yml
{{ ansible_facts['devices']['xvda']['model'] }}
```
同样，系统报告的主机名是：
```yml
{{ ansible_facts['nodename'] }}
```
Facts 经常用于[条件（参见条件）](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html#playbooks-conditionals)和模板中。

Facts 还可用于创建符合特定条件的动态主机组，有关详细信息，请参阅group_by上的导入模块文档，以及条件章节中讨论的通用条件语句。

## 禁用Facts
如果您知道自己不需要任何有关主机的事实数据，并且集中了解系统的所有信息，则可以关闭Facts收集。 这有利于在推送模式下使用大量系统扩展Ansible，主要是，或者如果您在实验平台上使用Ansible。 在任何play中，只需这样做：
```yml
- hosts: whatever
  gather_facts: no
```


# 参考
[https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html)

