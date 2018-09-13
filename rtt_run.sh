# Copyright 2018-present Ralf Kundel, Jeremias Blendin, Nikolas Eller
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

argsCommand=""

if [ "$1" = "--nopcap" ] || [ "$1" = "--nocli" ]; then
  argsCommand=$1" True"
fi

if [ "$2" = "--nopcap" ] || [ "$2" = "--nocli" ]; then
  argsCommand=$argsCommand" "$2" True"
fi

#compile p4 file
[ -e router_compiled.json ] && sudo rm -f router_compiled.json
p4c-bmv2 srcP4/router.p4 --json router_compiled.json

# Delays 0, 2, 5, 10, 20, 50
arr=("0" "2" "5" "10" "20" "50")

for i in "${arr[@]}"
do
  echo "Run: $i"
  #delete old pcap files
  sudo rm out/*.pcap

  sudo killall ovs-testcontroller
  sudo mn -c
  #start mininet environment
  sudo PYTHONPATH=$PYTHONPATH:../behavioral-model/mininet/ \
      python toposetup.py \
      --switch simple_switch -p4 \
      --json ./router_compiled.json \
      --cli simple_switch_CLI \
      --cliCmd commandsRouter1.txt \
      $argsCommand \
      --h3delay $i"ms"
  filename="iperf_output"$i".json"
  sudo mv out/iperf_output.json out/$filename
done