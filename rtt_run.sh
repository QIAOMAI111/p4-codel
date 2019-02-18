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

if [ "$1" = "--nopcap" ]; then
  argsCommand=$1" True"
fi

if [ "$1" = "--iperft" ]; then 
  argsCommand="--iperft "$2
fi

if [ "$2" = "--nopcap" ]; then
  argsCommand=$argsCommand" "$2" True"
fi

if [ "$2" = "--iperft" ]; then 
  argsCommand=$argsCommand" --iperft "$3
fi

if [ "$3" = "--nopcap" ]; then
  argsCommand=$argsCommand" "$3" True"
fi

argsCommand=$argsCommand" --nocli True"


#compile p4 file
[ -e router_compiled.json ] && sudo rm -f router_compiled.json
p4c-bm2-ss srcP4/router.p4 --std p4-16 -o router_compiled.json

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
      python srcPython/toposetup.py \
      --swpath ../behavioral-model/targets/simple_switch/simple_switch \
      --json ./router_compiled.json -p4 \
      --cli simple_switch_CLI \
      --cliCmd srcP4/commandsCodelRouter.txt \
      $argsCommand \
      --h3delay $i"ms"
  filename="iperf_output"$i".json"
  sudo mv out/iperf_output.json out/$filename
done
