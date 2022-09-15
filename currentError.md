Running starknet compile with cairoPath /home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp
Traceback (most recent call last):
  File "/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/warp_venv/bin/starknet-compile", line 7, in <module>
    from starkware.starknet.compiler.compile import main  # noqa
  File "/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/warp_venv/lib/python3.10/site-packages/starkware/starknet/compiler/compile.py", line 8, in <module>
    from starkware.cairo.lang.compiler.assembler import assemble
  File "/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/warp_venv/lib/python3.10/site-packages/starkware/cairo/lang/compiler/assembler.py", line 3, in <module>
    from starkware.cairo.lang.compiler.debug_info import DebugInfo, HintLocation, InstructionLocation
  File "/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/warp_venv/lib/python3.10/site-packages/starkware/cairo/lang/compiler/debug_info.py", line 11, in <module>
    from starkware.starkware_utils.validated_dataclass import ValidatedMarshmallowDataclass
  File "/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/warp_venv/lib/python3.10/site-packages/starkware/starkware_utils/validated_dataclass.py", line 12, in <module>
    from starkware.starkware_utils.validated_fields import Field
  File "/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/warp_venv/lib/python3.10/site-packages/starkware/starkware_utils/validated_fields.py", line 13, in <module>
    from starkware.starkware_utils.marshmallow_dataclass_fields import (
  File "/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/warp_venv/lib/python3.10/site-packages/starkware/starkware_utils/marshmallow_dataclass_fields.py", line 8, in <module>
    from frozendict import frozendict
  File "/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/warp_venv/lib/python3.10/site-packages/frozendict/__init__.py", line 16, in <module>
    class frozendict(collections.Mapping):
AttributeError: module 'collections' has no attribute 'Mapping'
Compile failed
Unexpected error during transpilation
CLIError: Compilation of cairo file warp_output/contracts/ERC721Collection__WC__ERC721Collection.cairo failed
    at computeClassHash (/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/build/utils/postCairoWrite.js:98:15)
    at addClassHash (/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/build/utils/postCairoWrite.js:91:21)
    at hashDependacies (/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/build/utils/postCairoWrite.js:71:9)
    at /home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/build/utils/postCairoWrite.js:61:9
    at Array.forEach (<anonymous>)
    at postProcessCairoFile (/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/build/utils/postCairoWrite.js:60:18)
    at /home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/build/index.js:51:59
    at Array.forEach (<anonymous>)
    at /home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/build/index.js:50:18
    at Array.forEach (<anonymous>)
    at Command.<anonymous> (/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/build/index.js:40:11)
    at Command.listener [as _actionHandler] (/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/node_modules/commander/lib/command.js:482:17)
    at /home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/node_modules/commander/lib/command.js:1265:65
    at Command._chainOrCall (/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/node_modules/commander/lib/command.js:1159:12)
    at Command._parseCommand (/home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/node_modules/commander/lib/command.js:1265:27)
    at /home/esdras/.nvm/versions/node/v18.9.0/lib/node_modules/@nethermindeth/warp/node_modules/commander/lib/command.js:1063:27
Transpilation failed