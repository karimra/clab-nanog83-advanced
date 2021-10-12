#!/bin/bash

set -e

# deploy the lab.
# if you have limited compute resources, limit the number of workers by
# uncommenting the `--max-workers 4` flag
sudo clab deploy -t nanog83.clab.yaml --reconfigure #--max-workers 4

# get SR Linux Nodes names and join them with a comma
srl_nodes=$(docker ps -f label=containerlab=nanog83 -f label=clab-node-kind=srl --format {{.Names}} | paste -s -d, -)
echo $srl_nodes

# configure interfaces via gNMI 
gnmic --log \
      -a ${srl_nodes} \
      --tls-ca clab-nanog83/ca/root/root-ca.pem \
      -u admin \
      -p admin \
      -e json_ietf \
      set \
      --request-file config/1.interfaces/interfaces_template.gotmpl \
      --request-vars config/1.interfaces/interfaces_template_vars.yaml

# configure subinterfaces via gNMI 
gnmic --log \
      -a ${srl_nodes} \
      --tls-ca clab-nanog83/ca/root/root-ca.pem \
      -u admin \
      -p admin \
      -e json_ietf \
      set \
      --request-file config/1.interfaces/subinterfaces_template.gotmpl \
      --request-vars config/1.interfaces/interfaces_template_vars.yaml

# configure routing policy prefix set via gNMI 
gnmic --log \
      -a ${srl_nodes} \
      --tls-ca clab-nanog83/ca/root/root-ca.pem \
      -u admin \
      -p admin \
      -e json_ietf \
      set \
      --request-file config/2.routing-policy/routing_policy_prefix_set_template.gotmpl \
      --request-vars config/2.routing-policy/routing_policy_vars.yaml

# configure routing policy policy via gNMI 
gnmic --log \
      -a ${srl_nodes} \
      --tls-ca clab-nanog83/ca/root/root-ca.pem \
      -u admin \
      -p admin \
      -e json_ietf \
      set \
      --request-file config/2.routing-policy/routing_policy_policy_template.gotmpl \
      --request-vars config/2.routing-policy/routing_policy_vars.yaml


# configure network-instance via gNMI 
gnmic --log \
      -a ${srl_nodes} \
      --tls-ca clab-nanog83/ca/root/root-ca.pem \
      -u admin \
      -p admin \
      -e json_ietf \
      set \
      --request-file config/3.network-instance/network_instance_template.gotmpl \
      --request-vars config/3.network-instance/network_instance_template_vars.yaml

# configure bgp via gNMI 
gnmic --log \
      -a ${srl_nodes} \
      --tls-ca clab-nanog83/ca/root/root-ca.pem \
      -u admin \
      -p admin \
      -e json_ietf \
      set \
      --request-file config/3.network-instance/network_instance_bgp_template.gotmpl \
      --request-vars config/3.network-instance/network_instance_template_vars.yaml

sleep 5

for node in $(docker ps -f label=clab-node-kind=srl --format {{.Names}})
do 
  bgp_state=$(gnmic -a $node --tls-ca clab-nanog83/ca/root/root-ca.pem -u admin -p admin -e ascii --format flat get --path /network-instance[name=default]/protocols/bgp/oper-state | awk '{print $NF}')
  echo "$(date): BGP state of $node is $bgp_state"
  if [ $bgp_state != "up" ]; then 
    exit 1
  fi
done
# watch bgp peers
while true
do 
echo ""
echo "$(date)"
gnmic -a clab-nanog83-spine11,clab-nanog83-spine12,clab-nanog83-spine21,clab-nanog83-spine22 \
      --tls-ca clab-nanog83/ca/root/root-ca.pem \
      -u admin \
      -p admin \
      -e ascii \
      --format flat \
      get \
      --path /network-instance[name=default]/protocols/bgp/oper-state \
      --path /network-instance[name=default]/protocols/bgp/neighbor/ipv4-unicast/oper-state
sleep 10
done
