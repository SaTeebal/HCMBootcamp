namespace: demo
flow:
  name: CreateVM
  inputs:
    - hostname: 10.0.46.10
    - username: "Capa1\\1268-capa1user"
    - password:
        default: Automation123
        sensitive: true
    - image: Ubuntu
    - folder: Students/Sateesh
    - prefix_list: '1-,2-,3-'
    - datacenter: Capa1 Datacenter
  workflow:
    - generate_uuid:
        do:
          io.cloudslang.demo.uuid: []
        publish:
          - uuid: '${"BSK-"+uuid}'
        navigate:
          - SUCCESS: substring
    - substring:
        do:
          io.cloudslang.base.strings.substring:
            - origin_string: '${uuid}'
            - end_index: '13'
        publish:
          - id: '${new_string}'
        navigate:
          - SUCCESS: clone_vm
          - FAILURE: on_failure
    - clone_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.vm.clone_vm:
              - host: '${hostname}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_source_identifier: name
              - vm_source: '${image}'
              - datacenter: '${datacenter}'
              - vm_name: '${prefix+id}'
              - vm_folder: '${folder}'
              - mark_as_template: 'false'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: power_on_vm
          - FAILURE: on_failure
    - power_on_vm:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.power_on_vm:
              - host: '${hostname}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: '${image}'
              - vm_name: '${prefix+id}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        navigate:
          - SUCCESS: wait_for_vm_info
          - FAILURE: on_failure
    - wait_for_vm_info:
        parallel_loop:
          for: prefix in prefix_list
          do:
            io.cloudslang.vmware.vcenter.util.wait_for_vm_info:
              - host: '${hostname}'
              - user: '${username}'
              - password:
                  value: '${password}'
                  sensitive: true
              - vm_identifier: name
              - vm_name: '${prefix+id}'
              - datacenter: '${datacenter}'
              - trust_all_roots: 'true'
              - x_509_hostname_verifier: allow_all
        publish:
          - ip_list: '${str([str(x["ip"])}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - ip_list: '${ip_list}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      generate_uuid:
        x: 100
        y: 150
      substring:
        x: 400
        y: 150
      clone_vm:
        x: 700
        y: 150
      power_on_vm:
        x: 1000
        y: 150
      wait_for_vm_info:
        x: 708
        y: 383
        navigate:
          291c36b4-6d9c-1148-0c86-ce008dba0d11:
            targetId: a94fee27-b5d9-e05c-1457-84b5076f348c
            port: SUCCESS
    results:
      SUCCESS:
        a94fee27-b5d9-e05c-1457-84b5076f348c:
          x: 1300
          y: 150
