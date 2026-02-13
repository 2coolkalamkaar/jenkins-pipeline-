#!/bin/bash
                            set -e
                            unzip -o /home/rahul/myapp.zip -d /home/rahul/app/
                            source /home/rahul/app/venv/bin/activate
                            cd /home/rahul/app/
                            pip install flask
                            sudo systemctl restart flaskapp.service
                            