import subprocess
import os
import sys

sys.path.append("Utils/python_utils/.")
import gridpack_lists as sampleLists

from color_style import style

"""Fields changed by user"""
StringToChange = 'privateMC'
condor_file_name = StringToChange
# storeAreaPath = '/dpm/indiacms.res.in/home/cms/store/user/ptiwari/t3store2/2018_BBDM_2HDMa'
storeAreaPath = '/eos/cms/store/group/phys_exotica/bbMET/llp_slimmer2017/signalsample'
storeAreaPathForlogs = '.'

"""Create log files"""
import infoCreaterGit
# SumamryOfCurrentSubmission = raw_input("\n\nWrite summary for current job submission: ")
SumamryOfCurrentSubmission = "\n\nWrite summary for current job submission: "
infoLogFiles = infoCreaterGit.BasicInfoCreater('summary.dat',SumamryOfCurrentSubmission)
infoLogFiles.GenerateGitPatchAndLog()

"""Create directories for storing log files and output files at EOS."""
import fileshelper
dirsToCreate = fileshelper.FileHelper('condor_logs/'+StringToChange, storeAreaPathForlogs)
output_log_path = dirsToCreate.CreateLogDirWithDate()
dirTag = dirsToCreate.dirName
"""Create directories for different models at EOS"""
for key in sampleLists.models:
  if key == 'radion':
    for gridpcaks in sampleLists.models[key]:
        DirName = gridpcaks.split('/')[-1].split('_')
        DirName = DirName[0]+'_'+DirName[1]+'_'+DirName[2]+'_'+DirName[3]
        storeDir = dirsToCreate.createStoreDirWithDate(StringToChange,DirName)
        print(storeDir)
        infoLogFiles.SendGitLogAndPatchToEos(storeDir)


import condorJobHelper
listOfFilesToTransfer = 'EXO-LLP_GEN_cfg.py, EXO-LLP_GEN-SIM_cfg.py, EXO-LLP_DIGIPremix_cfg.py, EXO-LLP_HLT_cfg.py, EXO-LLP_RECO_cfg.py, EXO-LLP_MiniAOD_cfg.py, dummyFile'
condorJobHelper = condorJobHelper.condorJobHelper(condor_file_name,
                                                  listOfFilesToTransfer,
                                                  12000,    # request_memory 12000
                                                  8,    # request_cpus 8
                                                  output_log_path,
                                                  'test',   # logFileName
                                                  "",   # Arguments
                                                  2 # Queue
                                                  )
jdlFile = condorJobHelper.jdlFileHeaderCreater()
print('==> jdlfile name: ',jdlFile)

for key in sampleLists.models:
  print(key)
  if key == 'bbdm':
    for gridpcaks in sampleLists.models[key]:
        DirName = gridpcaks.split('/')[-1].split('_')
        DirName = DirName[0]+'_'+DirName[1]+'_'+DirName[2]+'_'+DirName[3]+'_'+DirName[4]+'_'+DirName[5]
        condorJobHelper.logFileName = DirName
        condorJobHelper.Arguments = 'EXO-LLP_GEN_cfg.py '+DirName + \
            os.sep+dirTag + '  '+gridpcaks.replace('/', '\/')
        jdlFile = condorJobHelper.jdlFileAppendLogInfo()

outScript = open(condor_file_name+".sh","w")

outScript.write('#!/bin/bash')
outScript.write('\n'+'echo "Starting job on " `date`')
outScript.write('\n'+'echo "Running on: `uname -a`"')
outScript.write('\n'+'echo "System software: `cat /etc/redhat-release`"')
outScript.write('\n'+'source /cvmfs/cms.cern.ch/cmsset_default.sh')
outScript.write('\n'+'echo "'+'#'*51+'"')
outScript.write('\n'+'echo "#    List of Input Arguments: "')
outScript.write('\n'+'echo "'+'#'*51+'"')
outScript.write('\n'+'echo "Input Arguments: $1"')
outScript.write('\n'+'echo "Input Arguments: $2"')
outScript.write('\n'+'echo "Input Arguments: $3"')
outScript.write('\n'+'echo "Input Arguments: $4"')
outScript.write('\n'+'echo "Input Arguments: $5"')
outScript.write('\n'+'echo "'+'#'*51+'"')
outScript.write('\n'+'')
# outScript.write('\n'+'OUTDIR=root://se01.indiacms.res.in/'+storeAreaPath+os.sep+StringToChange+'/${4}/')
outScript.write('\n'+'OUTDIR=root://eoscms.cern.ch/'+storeAreaPath+os.sep+StringToChange+'/${4}/')
outScript.write('\n'+'')
outScript.write('\n'+'echo "======="')
outScript.write('\n'+'ls')
outScript.write('\n'+'echo "======="')
outScript.write('\n'+'')
outScript.write('\n'+'export SCRAM_ARCH=slc7_amd64_gcc700')
outScript.write('\n'+'echo $PWD')
outScript.write('\n'+'eval `scramv1 project CMSSW CMSSW_10_2_21`')
outScript.write('\n'+'cd CMSSW_10_2_21/src/')
outScript.write('\n'+'# set cmssw environment')
outScript.write('\n'+'eval `scram runtime -sh`')
outScript.write('\n'+'cd -')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> List all files..."')
outScript.write('\n'+'ls ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "==> Running GEN step"')
outScript.write("\n"+'sed -i "s/args = cms.vstring.*/args = cms.vstring(\\"${5}\\"),/g" EXO-LLP_GEN_cfg.py ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "==> EXO-LLP_GEN_cfg.py"')
outScript.write('\n'+'cmsRun EXO-LLP_GEN_cfg.py ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "List all root files = "')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'ls *.root')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'')
outScript.write('\n'+'echo "Loading CMSSW env for SIM step"')
outScript.write('\n'+'eval `scramv1 project CMSSW CMSSW_10_6_25`')
outScript.write('\n'+'cd CMSSW_10_6_25/src/')
outScript.write('\n'+'# set cmssw environment')
outScript.write('\n'+'eval `scram runtime -sh`')
outScript.write('\n'+'cd -')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "cmsRun EXO-LLP_GEN-SIM_cfg.py"')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'cmsRun EXO-LLP_GEN-SIM_cfg.py ')
outScript.write('\n'+'echo "List all root files = "')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'ls *.root')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'')
outScript.write('\n'+'echo "==> EXO-LLP_DIGIPremix_cfg.py" ')
outScript.write('\n'+'cmsRun EXO-LLP_DIGIPremix_cfg.py  ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "List all root files = "')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'ls *.root')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'')
outScript.write('\n'+'echo "Loading CMSSW env for HLT step"')
outScript.write('\n'+'eval `scramv1 project CMSSW CMSSW_9_4_14_UL_patch1`')
outScript.write('\n'+'cd CMSSW_9_4_14_UL_patch1/src/')
outScript.write('\n'+'# set cmssw environment')
outScript.write('\n'+'eval `scram runtime -sh`')
outScript.write('\n'+'cd -')
outScript.write('\n'+'echo "==> cmsRun EXO-LLP_HLT_cfg.py"')
outScript.write('\n'+'cmsRun EXO-LLP_HLT_cfg.py ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "List all root files = "')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'ls *.root')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'')
outScript.write('\n'+'export SCRAM_ARCH=slc7_amd64_gcc700')
outScript.write('\n'+'echo "Loading CMSSW env for RECO step"')
outScript.write('\n'+'eval `scramv1 project CMSSW CMSSW_10_6_25`')
outScript.write('\n'+'cd CMSSW_10_6_25/src/')
outScript.write('\n'+'# set cmssw environment')
outScript.write('\n'+'eval `scram runtime -sh`')
outScript.write('\n'+'cd -')
outScript.write('\n'+'echo "==> cmsRun EXO-LLP_RECO_cfg.py"')
outScript.write('\n'+'cmsRun EXO-LLP_RECO_cfg.py')
outScript.write('\n'+'echo "==> cmsRun EXO-LLP_MiniAOD_cfg.py"')
outScript.write('\n'+'cmsRun EXO-LLP_MiniAOD_cfg.py')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> List all files..."')
outScript.write('\n'+'echo "pwd : ${PWD}"')
outScript.write('\n'+'ls ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "List all root files = "')
outScript.write('\n'+'ls *.root')
outScript.write('\n'+'echo "List all files"')
outScript.write('\n'+'ls ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'')
outScript.write('\n'+'# copy output to eos')
outScript.write('\n'+'echo "xrdcp output for condor"')
outScript.write('\n'+'mv EXO-LLP_MiniAOD.root  EXO-LLP_RunIIFall17MiniAODv2_${1}_${2}.root')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> List all files..."')
outScript.write('\n'+'ls *.root ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "xrdcp output for condor"')
outScript.write('\n'+'xrdcp -f EXO-LLP_RunIIFall17MiniAODv2_${1}_${2}.root ${OUTDIR}/EXO-LLP_RunIIFall17MiniAODv2_${1}_${2}.root')
outScript.write('\n'+'echo "========================="')
outScript.write('\n'+'echo "==> List all files..."')
outScript.write('\n'+'ls *.root ')
outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'date')
outScript.write('\n'+'')
outScript.write('\n'+'')
# outScript.write('\n'+'echo "+=============================="')
# outScript.write('\n'+'echo "==> Running NanoAOD..."')
# outScript.write('\n'+'eval `scramv1 project CMSSW CMSSW_10_2_18`')
# outScript.write('\n'+'cd CMSSW_10_2_18/src')
# outScript.write('\n'+'echo $PWD')
# outScript.write('\n'+'eval `scram runtime -sh`')
# outScript.write('\n'+'cd -')
# outScript.write('\n'+'cmsRun B2G-RunIIAutumn18NanoAODv6-01916_1_cfg.py')
# outScript.write('\n'+'echo "List all root files = "')
# outScript.write('\n'+'ls *.root')
# outScript.write('\n'+'echo "+=============================="')
# outScript.write('\n'+'# copy output to eos')
# outScript.write('\n'+'echo "xrdcp output for condor"')
# outScript.write('\n'+'echo "xrdcp -f B2G-RunIIAutumn18NanoAODv6-01916.root ${OUTDIR}/out_NanoAOD_${1}_${2}.root"')
# outScript.write('\n'+'echo "+=============================="')
# outScript.write('\n'+'xrdcp -f B2G-RunIIAutumn18NanoAODv6-01916.root ${OUTDIR}/out_NanoAOD_${1}_${2}.root')
# outScript.write('\n'+'echo "+=============================="')
outScript.write('\n'+'echo "Done."')
outScript.write('\n'+'date')

outScript.close()

os.system("chmod 777 "+condor_file_name+".sh")

print("===> Set Proxy Using:")
print("\tvoms-proxy-init --voms cms --valid 168:00")
print("\"condor_submit "+condor_file_name+".jdl\" to submit")
