#!/bin/bash
echo "Starting job on " `date`
echo "Running on: `uname -a`"
echo "System software: `cat /etc/redhat-release`"
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc700
echo "###################################################"
echo "#    List of Input Arguments: "
echo "###################################################"
echo "Input Arguments: $1"
echo "Input Arguments: $2"
echo "Input Arguments: $3"
echo "Input Arguments: $4"
echo "Input Arguments: $5"
echo "Input Arguments: $6"
echo "###################################################"

OUTDIR=root://se01.indiacms.res.in//dpm/indiacms.res.in/home/cms/store/user/ptiwari/t3store2/2016_BBDM_2HDMa/privateMC16/${4}/

echo "======="
ls
echo "======"

echo $PWD
eval `scramv1 project CMSSW CMSSW_7_1_38`
cd CMSSW_7_1_38/src/
# set cmssw environment
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> List all files..."
ls 
echo "+=============================="
echo "==> Running GEN-SIM step (1001 events will be generated)"
sed -i "s/args = cms.vstring.*/args = cms.vstring(\"${5}\"),/g" EXO-RunIISummer15wmLHEGS-06994_1_cfg.py 
echo "+=============================="
echo "+=============================="
cmsRun EXO-RunIISummer15wmLHEGS-06994_1_cfg.py 
echo "List all root files = "
ls *.root
echo "List all files"
date
echo "+=============================="

echo "Loading CMSSW env DR1, DR2 and MiniAOD"
eval `scramv1 project CMSSW CMSSW_8_0_31`
cd CMSSW_8_0_31/src/
# set cmssw environment
eval `scram runtime -sh`
cd -

echo "========================="
echo "==> List all files..."
echo "pwd : ${PWD}"
ls 
echo "+=============================="
echo "==> cmsRun EXO-RunIISummer16DR80Premix-14543_1_cfg.py" 
cmsRun EXO-RunIISummer16DR80Premix-14543_1_cfg.py
echo "==> cmsRun EXO-RunIISummer16DR80Premix-14543_2_cfg.py"
cmsRun EXO-RunIISummer16DR80Premix-14543_2_cfg.py 
eval `scramv1 project CMSSW CMSSW_9_4_9`
cd CMSSW_9_4_9/src/
# set cmssw environment
eval `scram runtime -sh`
cd -
echo "==> cmsRun EXO-RunIISummer16MiniAODv3-12495_1_cfg.py"
cmsRun EXO-RunIISummer16MiniAODv3-12495_1_cfg.py
echo "========================="
echo "==> List all files..."
echo "pwd : ${PWD}"
ls 
echo "+=============================="
echo "List all root files = "
ls *.root
echo "List all files"
ls 
echo "+=============================="

# copy output to eos
echo "xrdcp output for condor"
mv EXO-RunIISummer16MiniAODv3-12495.root  EXO-RunIISummer16MiniAODv3_${1}_${2}.root
echo "========================="
echo "==> List all files..."
ls *.root 
echo "+=============================="
echo "xrdcp output for condor"
xrdcp -f EXO-RunIISummer16MiniAODv3_${1}_${2}.root ${OUTDIR}/EXO-RunIISummer16MiniAODv3_${1}_${2}.root
echo "========================="
echo "==> List all files..."
ls *.root 
echo "+=============================="
date


echo "Done."
date
