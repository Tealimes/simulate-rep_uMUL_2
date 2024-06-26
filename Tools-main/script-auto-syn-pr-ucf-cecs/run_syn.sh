#!/bin/bash
# this is a shell script to run dc synthesis for all *.sv files in this foler
# note that the *.sv files require identical file and module name

set -e
set -o noclobber


echo ""
echo "***************************Start Synthesis**************************"
# check the existance of dc setup file and dc run script
SETUPFILE=.synopsys_dc.setup
SRCSETUPFILE=synopsys_dc.setup
if [ ! -f $SETUPFILE ]; then
    if [ -f $SRCSETUPFILE ]; then
        mv $SRCSETUPFILE $SETUPFILE
    else
        echo ""
        echo "Design Compiler setup file $SETUPFILE or $SRCSETUPFILE does not exist."
        return 0
    fi
fi

DCSCRIPT=script_syn.tcl
if [ ! -f $DCSCRIPT ]; then
    echo ""
    echo "Design Compiler script $DCSCRIPT does not exist."
    return 0
fi

svsuff=sv
vsuff=v

# rename *.v to *.sv
echo ""
echo "Check *.v files:"
if ls *.$svsuff; then
    for dut in $(ls *.$svsuff)
    do
        echo "Find system verilog src file: $dut"
    done
fi

echo ""
echo "Synthesize designs in *.v files:"

# process only top design
dutname="$(basename $PWD)"
if [ -e $dutname.$vsuff ]
then
    echo "Find top design file <$dutname.$vsuff>."
else
    echo "Missing top design file <$dutname.$vsuff>."
    exit 0
fi
echo "Process design $dutname."
sed -i "s/dut/$dutname/g" $DCSCRIPT
rm -rf work/ *.vg *.vf
dc_shell -f $DCSCRIPT >| $dutname.syn.rpt
sed -i "s/$dutname/dut/g" $DCSCRIPT
echo "    Complete."
sleep 10s

# process all designs
# if ls *.$vsuff; then
#     for dut in $(ls *.$vsuff)
#     do
#         dutname="${dut%.*}"
#         echo "Processing design $dutname in $dut..."
#         sed -i "s/dut/$dutname/g" $DCSCRIPT
#         rm -rf work/ *.vg *.vf
#         dc_shell -f $DCSCRIPT >| $dutname.syn.rpt
#         sed -i "s/$dutname/dut/g" $DCSCRIPT
#         echo "    Done"
#         sleep 10s
#     done
# else
#     echo "No design exists."
#     return 0
# fi

echo ""
echo "Check potential errors in log:"
grep -Ri "Error" ./*
grep -Ri "connected" ./*
echo ""
echo "******************************All Done******************************"
echo ""


