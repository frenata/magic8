set -eu

old_version=$(aws ec2 describe-launch-template-versions --launch-template-name magic8-lt | jq ".LaunchTemplateVersions[0].VersionNumber")
echo The old template version is: $old_version
out=$(aws ec2 create-launch-template-version --launch-template-name magic8-lt --source-version $old_version --launch-template-data "{\"ImageId\": \"$1\"}")
new_version=$(echo $out | jq '.LaunchTemplateVersion.VersionNumber')
echo The new template version is: $new_version
aws ec2 modify-launch-template --launch-template-name magic8-lt --default-version $new_version
aws autoscaling start-instance-refresh --auto-scaling-group-name magic8-auto --desired-configuration "{\"LaunchTemplate\": {\"LaunchTemplateName\": \"magic8-lt\", \"Version\": \"\$Default\"}}"
