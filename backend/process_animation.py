import sys
import os
import subprocess

job_id = sys.argv[1]

from app import jobs, process_job

process_job(job_id)
