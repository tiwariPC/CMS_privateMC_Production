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

OUTDIR=root://se01.indiacms.res.in//dpm/indiacms.res.in/home/cms/store/user/ptiwari/t3store2/2017_BBDM_2HDMa/privateMC/${4}/

echo "======="
ls
echo "======"

echo $PWD
eval `scramv1 project CMSSW CMSSW_9_3_14`
cd CMSSW_9_3_14/src/
# set cmssw environment
eval `scram runtime -sh`
cd -
echo "========================="
echo "==> List all files..."
ls 
echo "+=============================="
echo "==> Running GEN-SIM step (1001 events will be generated)"
sed -i "s/args = cms.vstring.*/args = cms.vstring(\"${5}\"),/g" EXO-RunIIFall17wmLHEGS-02213_1_cfg.py 
echo "+=============================="
cat EXO-RunIIFall17wmLHEGS-02213_1_cfg.py 
echo "+=============================="
cmsRun EXO-RunIIFall17wmLHEGS-02213_1_cfg.py 
echo "List all root files = "
ls *.root
echo "List all files"
date
echo "+=============================="

echo "Loading CMSSW env DR1, DR2 and MiniAOD"
eval `scramv1 project CMSSW CMSSW_9_4_7`
cd CMSSW_9_4_7/src/
# set cmssw environment
eval `scram runtime -sh`
cd -

echo "========================="
echo "==> List all files..."
echo "pwd : ${PWD}"
ls 
echo "+=============================="
echo "==> cmsRun EXO-RunIIFall17DRPremix-05692_1_cfg.py" 
cmsRun EXO-RunIIFall17DRPremix-05692_1_cfg.py  
echo "==> cmsRun EXO-RunIIFall17DRPremix-05692_2_cfg.py"
cmsRun EXO-RunIIFall17DRPremix-05692_2_cfg.py 
echo "==> cmsRun EXO-RunIIFall17MiniAODv2-05632_1_cfg.py"
cmsRun EXO-RunIIFall17MiniAODv2-05632_1_cfg.py
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
mv EXO-RunIIFall17MiniAODv2-05632.root  EXO-RunIIFall17MiniAODv2_${1}_${2}.root
echo "========================="
echo "==> List all files..."
ls *.root 
echo "+=============================="
echo "xrdcp output for condor"
xrdcp -f EXO-RunIIFall17MiniAODv2_${1}_${2}.root ${OUTDIR}/EXO-RunIIFall17MiniAODv2_${1}_${2}.root
echo "========================="
echo "==> List all files..."
ls *.root 
echo "+=============================="
date


echo "Done."
date