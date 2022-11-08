#!/bin/bash -eu

# This is a streamlined version of the script by the same name in the
# WordPress iOS repo.
#
# Before modifying this, checkout the original to see if there have been
# improvements.
#
# https://github.com/wordpress-mobile/WordPress-iOS/blob/a81ed8b7c0fa91689431178ba132813f082c67da/Scripts/BuildPhases/GenerateCredentials.sh

SECRETS_ROOT="${HOME}/.configure/wordpress-authenticator-ios-demo/secrets"

# To help the Xcode build system optimize the build, we want to ensure each of
# the secrets to copy is defined as an input file for the run script build
# phase.
#
# > The Xcode Build System will use [these files] to determine if your run
# > scripts should actually run or not. So this should include any file that
# > your run script phase, the script content, is actually going to read or
# > look at during its process.
#
# > If you have no input files declared, the Xcode build system will need to
# > run your run script phase on every single build.
#
# https://developer.apple.com/videos/play/wwdc2018/408/
function ensure_is_in_input_files_list() {
  # Loop through the file input lists looking for $1. If not found, fail the
  # build.
  if [ -z "$1" ]; then
    echo "error: Input file list verification needs a path to verify!"
    exit 1
  fi
  file_to_find=$1

  i=0
  found=false
  while [[ $i -lt $SCRIPT_INPUT_FILE_LIST_COUNT && "$found" = false ]]
  do
    # Need this two step process to access the input at index
    file_list_resolved_var_name=SCRIPT_INPUT_FILE_LIST_${i}
    # The following reads the processed xcfilelist line by line looking for
    # the given file
    while read -r input_file; do
      if [ "$file_to_find" == "$input_file" ]; then
        found=true
        break
      fi
    done <"${!file_list_resolved_var_name}"
    (( i=i+1 ))
  done
  if [ "$found" = false ]; then
    echo "error: Could not find $file_to_find as an input to the build phase. Add $file_to_find to the input files list using the .xcfilelist."
    exit 1
  fi
}

SECRETS_FILE="${SECRETS_ROOT}/Secrets.swift"
ensure_is_in_input_files_list "$SECRETS_FILE"

LOCAL_SECRETS_FILE="${SRCROOT}/Secrets.swift"
EXAMPLE_SECRETS_FILE="${SRCROOT}/AuthenticatorDemo/Secrets.example.swift"
ensure_is_in_input_files_list "$EXAMPLE_SECRETS_FILE"

SECRETS_DESTINATION_FILE="${BUILD_DIR}/Secrets.swift"
mkdir -p "$(dirname "$SECRETS_DESTINATION_FILE")"

# If the secrets are available, use them
if [ -f "$SECRETS_FILE" ]; then
    echo "Applying secrets"
    cp -v "$SECRETS_FILE" "${SECRETS_DESTINATION_FILE}"
    exit 0
fi

# If the developer has a local secrets file, use it
if [ -f "$LOCAL_SECRETS_FILE" ]; then
    echo "warning: Using local secrets from $LOCAL_SECRETS_FILE. If you are an external contributor, this is expected and you can ignore this warning. If you are an internal contributor, make sure to use our shared credentials instead."
    echo "Applying local secrets"
    cp -v "$LOCAL_SECRETS_FILE" "${SECRETS_DESTINATION_FILE}"
    exit 0
fi

# None of the above secrets was found. Use the example secrets file as a last
# resort.

COULD_NOT_FIND_SECRET_MSG="Could not find secrets file at ${SECRETS_DESTINATION_FILE}. This is likely due to the source secrets being missing from ${SECRETS_ROOT}"
INTERNAL_CONTRIBUTOR_MSG="If you are an internal contributor, run \`bundle exec fastlane run configure_apply\` to update your secrets and try again"
EXTERNAL_CONTRIBUTOR_MSG="If you are an external contributor, run \`cp $EXAMPLE_SECRETS_FILE $LOCAL_SECRETS_FILE\` to create a local secrets file and then add your own credentials in it (the file is ignored by Git)"

echo "warning: $COULD_NOT_FIND_SECRET_MSG. Falling back to $EXAMPLE_SECRETS_FILE. $INTERNAL_CONTRIBUTOR_MSG. $EXTERNAL_CONTRIBUTOR_MSG."
echo "Applying example secrets"
cp -v "$EXAMPLE_SECRETS_FILE" "${SECRETS_DESTINATION_FILE}"
