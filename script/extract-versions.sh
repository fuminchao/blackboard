#!/bin/bash

function PrintManifest() {
while read
do
  LN=`echo "$REPLY" | tr -d '\r'`
  if [[ ${LN:0:1} = ' ' ]]; then
    PREVLN="$PREVLN${LN:1}"
  else
    echo "$PREVLN"
    PREVLN=$LN
  fi
done <<EOF
`unzip -p $1 META-INF/MANIFEST.MF`
EOF
echo "$PREVLN"
}

find $BBHOME -name "*.[wj]ar" -type f | while read JAR
do
  unzip -l "$JAR" META-INF/MANIFEST.MF >> /dev/null || continue;

  PrintManifest "$JAR"  | grep -E "(X\-Bb\-Repository|X\-Bb\-Commit): "
  [[ "$?" = "0" ]] && echo "X-Bb-File: $JAR" && echo
done