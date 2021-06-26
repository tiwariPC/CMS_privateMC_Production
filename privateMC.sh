#!/bin/bash
echo "Starting job on " `date`
echo "Running on: `uname -a`"
echo "System software: `cat /etc/redhat-release`"
/cvmfs/cms.cern.ch/common/cmssw-cc6
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

OUTDIR=root://se01.indiacms.res.in//dpm/indiacms.res.in/home/cms/store/user/ptiwari/t3store2/BBDM_2HDMa_2016/privateMC/${4}/

echo "======="
ls
echo "======"

echo $PWD
eval `scramv1 project CMSSW CMSSW_9_4_0`
cd CMSSW_9_4_0/src/
# set cmssw environment
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> List all files..."
ls 
echo "+=============================="
echo "==> Running GEN-SIM step (1001 events will be generated)"
sed -i "s/args = cms.vstring.*/args = cms.vstring(\"${5}\"),/g" gensim_cfg.py 
echo "+=============================="
cat gensim_cfg.py 
echo "+=============================="
cmsRun gensim_cfg.py 
echo "List all root files = "
ls *.root
echo "List all files"
date
echo "+=============================="

echo "Loading CMSSW env DR1, DR2 and MiniAOD"

echo "========================="
echo "==> List all files..."
echo "pwd : ${PWD}"
ls 
echo "+=============================="
echo "==> cmsRun step1_DIGIPREMIX_S2_DATAMIX_L1_DIGI2RAW_HLT.py" 
cmsRun step1_DIGIPREMIX_S2_DATAMIX_L1_DIGI2RAW_HLT.py  
echo "==> cmsRun step2_RAW2DIGI_RECO_EI.py"
cmsRun step2_RAW2DIGI_RECO_EI.py 
echo "==> cmsRun step3_PAT.py"
cmsRun step3_PAT.py
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
cp MINIAODSIM.root out_MiniAOD_${1}_${2}.root
echo "========================="
echo "==> List all files..."
ls *.root 
echo "+=============================="
echo "xrdcp output for condor"
xrdcp -f out_MiniAOD_${1}_${2}.root ${OUTDIR}/out_MiniAOD_${1}_${2}.root
echo "========================="
echo "==> List all files..."
ls *.root 
echo "+=============================="
date


echo "Done."
date