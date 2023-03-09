#!/bin/bash
echo "Starting job on " `date`
echo "Running on: `uname -a`"
echo "System software: `cat /etc/redhat-release`"
source /cvmfs/cms.cern.ch/cmsset_default.sh
echo "###################################################"
echo "#    List of Input Arguments: "
echo "###################################################"
echo "Input Arguments: $1"
echo "Input Arguments: $2"
echo "Input Arguments: $3"
echo "Input Arguments: $4"
echo "Input Arguments: $5"
echo "###################################################"

OUTDIR=root://eoscms.cern.ch//eos/cms/store/group/phys_exotica/bbMET/llp_slimmer2017/signalsample/privateMC/${4}/

echo "======="
ls
echo "======="

export SCRAM_ARCH=slc7_amd64_gcc700
echo $PWD
eval `scramv1 project CMSSW CMSSW_10_2_21`
cd CMSSW_10_2_21/src/
# set cmssw environment
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> List all files..."
ls 
echo "+=============================="
echo "==> Running GEN step"
sed -i "s/args = cms.vstring.*/args = cms.vstring(\"${5}\"),/g" EXO-LLP_GEN_cfg.py 
echo "+=============================="
echo "==> EXO-LLP_GEN_cfg.py"
cmsRun EXO-LLP_GEN_cfg.py 
echo "+=============================="
echo "List all root files = "
echo "pwd : ${PWD}"
ls *.root
echo "+=============================="

echo "Loading CMSSW env for SIM step"
eval `scramv1 project CMSSW CMSSW_10_6_25`
cd CMSSW_10_6_25/src/
# set cmssw environment
eval `scram runtime -sh`
cd -
echo "+=============================="
echo "cmsRun EXO-LLP_GEN-SIM_cfg.py"
echo "+=============================="
cmsRun EXO-LLP_GEN-SIM_cfg.py 
echo "List all root files = "
echo "pwd : ${PWD}"
ls *.root
echo "+=============================="

echo "==> EXO-LLP_DIGIPremix_cfg.py" 
cmsRun EXO-LLP_DIGIPremix_cfg.py  
echo "+=============================="
echo "List all root files = "
echo "pwd : ${PWD}"
ls *.root
echo "+=============================="

echo "Loading CMSSW env for HLT step"
eval `scramv1 project CMSSW CMSSW_9_4_14_UL_patch1`
cd CMSSW_9_4_14_UL_patch1/src/
# set cmssw environment
eval `scram runtime -sh`
cd -
echo "==> cmsRun EXO-LLP_HLT_cfg.py"
cmsRun EXO-LLP_HLT_cfg.py 
echo "+=============================="
echo "List all root files = "
echo "pwd : ${PWD}"
ls *.root
echo "+=============================="

export SCRAM_ARCH=slc7_amd64_gcc700
echo "Loading CMSSW env for RECO step"
eval `scramv1 project CMSSW CMSSW_10_6_25`
cd CMSSW_10_6_25/src/
# set cmssw environment
eval `scram runtime -sh`
cd -
echo "==> cmsRun EXO-LLP_RECO_cfg.py"
cmsRun EXO-LLP_RECO_cfg.py
echo "==> cmsRun EXO-LLP_MiniAOD_cfg.py"
cmsRun EXO-LLP_MiniAOD_cfg.py
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
mv EXO-LLP_MiniAOD.root  EXO-LLP_RunIIFall17MiniAODv2_${1}_${2}.root
echo "========================="
echo "==> List all files..."
ls *.root 
echo "+=============================="
echo "xrdcp output for condor"
xrdcp -f EXO-LLP_RunIIFall17MiniAODv2_${1}_${2}.root ${OUTDIR}/EXO-LLP_RunIIFall17MiniAODv2_${1}_${2}.root
echo "========================="
echo "==> List all files..."
ls *.root 
echo "+=============================="
date


echo "Done."
date