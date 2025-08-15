# K8S The Hard Way With DigitalOcean
Quick log of custom steps for my run of kubernetes-the-hard-way.

Note the process below is from memory and isn't tested.

## Flow
0) Login with each cloud:
```
az login
doctl auth init
```

1) Read `0_tfstate_bootstrap.sh`, update with your own subscription_id, then run it.

2) Create an .env file in the repo root. Populate it with:
- `TF_VAR_do_token`: passing your digitalocean PAT token

3) In digitalocean, add your public ssh key from your local machine. Give it
the name "my_local", or update the data block in main.tf with the name you
choose.

4) Update `settings.auto.tfvars` with your subscription_id. Ensure `jumpbox_provisioned = false` for now.

5) Provision via
```terraform
terraform init
terraform apply
```

6) Optionally, append the machines to your ssh config using `1_ssh_bootstrap.sh`
```sh
./1_ssh_bootstrap >> ~/.ssh/config
```

This lets you write `ssh server` instead of `ssh root@server`, and allows X11 forwarding if you're on X11 and want your clipboard to work nicely.

7) Run `2_create_machines_txt.sh`, creating a machines.txt and machines_private.txt on the jumpbox. You need the machines_private.txt for step 11 on digitalocean.

8) Either follow step 2 in the `kubernetes-the-hard-way` docs, or run `3_jumpbox_boostrap.sh`

9) Follow step 3 to generate an ssh key on your jumpbox. Then, print it with `cat ~/.ssh/id_rsa.pub`, copy that over to digitalocean, and save it with the name `jumpbox`.

Then, in `settings.auto.tfvars`, set `jumpbox_provisioned` to `true`.

Finally, run
```terraform
terraform apply
```

This replaces the section in step 3 of `kubernetes-the-hard-way`, setting up ssh access from the jumpbox to your machines.

10) Follow the rest of the tutorial, until you hit step 11.

11) On step 11, amend the commands to use private IPs for the nodes, ie.
```
{
  SERVER_IP=$(grep server machines.txt | cut -d " " -f 1)
  NODE_0_IP=$(grep node-0 machines_private.txt | cut -d " " -f 1)
  NODE_0_SUBNET=$(grep node-0 machines_private.txt | cut -d " " -f 4)
  NODE_1_IP=$(grep node-1 machines_private.txt | cut -d " " -f 1)
  NODE_1_SUBNET=$(grep node-1 machines_private.txt | cut -d " " -f 4)
}
```

Without this modification, you'll get "Nexthop has invalid gateway" errors as you do `ip route add`. DigitalOcean doesn't allow public IPs as routing gateways.

12) Finish the tutorial.

13) For cleanup, run
```
terraform destroy
```

Then, read `4_tfstate_teardown.sh`, update with your subscription_id, and run it to clean up the tfstate storage account.

