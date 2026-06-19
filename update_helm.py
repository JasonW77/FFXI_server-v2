import os
import re

scripts_dir = 'scripts/zones'

for root, dirs, files in os.walk(scripts_dir):
    for file in files:
        if file in ['Mining_Point.lua', 'Harvesting_Point.lua', 'Logging_Point.lua', 'Excavation_Point.lua']:
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            
            # Extract the csid from onTrade
            # Example: xi.helm.onTrade(player, npc, trade, xi.helm.type.HARVESTING, 70)
            match = re.search(r'xi\.helm\.onTrade\(player, npc, trade, (xi\.helm\.type\.[A-Z]+),\s*(\d+)\)', content)
            
            if match:
                helm_type = match.group(1)
                csid = match.group(2)
                
                # Replace onTrigger
                # entity.onTrigger = function(player, npc)
                #     xi.helm.onTrigger(player, xi.helm.type.HARVESTING)
                # end
                
                old_trigger = r'entity\.onTrigger = function\(player, npc\)\s+xi\.helm\.onTrigger\(player, (xi\.helm\.type\.[A-Z]+)\)\s+end'
                new_trigger = f'entity.onTrigger = function(player, npc)\n    xi.helm.onTrigger(player, npc, {helm_type}, {csid})\nend'
                
                new_content = re.sub(old_trigger, new_trigger, content)
                
                with open(filepath, 'w', newline='\n') as f:
                    f.write(new_content)
                print(f"Updated {filepath}")
            else:
                print(f"Could not find csid in {filepath}")
