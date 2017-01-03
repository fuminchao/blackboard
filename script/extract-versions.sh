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

for SDIR in "$BBHOME"
do
  find $SDIR -name "*.[wj]ar" -type f \
    -not -path "*/backups/*" -prune \
    -not -path "*/__MACOSX/*" -prune \
    -not -path "*/tomcat/work/Catalina/localhost/webapps#*" -prune \
    -not -name "strut*.jar" \
    -not -name "spring*.jar" \
    -not -name "axis2-*.jar" \
    -not -name "hibernate-*.jar" \
    -not -name "activemq-*.jar" \
    -not -name "commons-*.jar" \
  | while read JAR
  do
    unzip -l "$JAR" META-INF/MANIFEST.MF >> /dev/null || continue;
    BB_LINES=`PrintManifest "$JAR"  | grep -E "(X\-Bb\-Repository|X\-Bb\-Commit): "`
    if [[ "$?" = "0" ]]; then
      BB_REPO=`echo $BB_LINES | sort | tr '\n' ' ' | cut -d' ' -f4`
      BB_COMM=`echo $BB_LINES | sort | tr '\n' ' ' | cut -d' ' -f2`
      echo "$BB_REPO#$BB_COMM $JAR"
    fi
  done
done