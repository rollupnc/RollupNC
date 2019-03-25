FROM node:11


WORKDIR /usr/src/roll_up

RUN npm install -g circom
RUN npm install -g snarkjs

RUN git clone https://github.com/iden3/circomlib
RUN cd circomlib;npm install;cd ..

# RUN git clone https://github.com/GuthL/roll_up_circom_tutorial
RUN git clone https://github.com/barryWhiteHat/RollupNC/tree/withdraw
RUN cp -r roll_up_circom_tutorial/leaf_update circomlib/
RUN cp -r roll_up_circom_tutorial/signature_verification circomlib/
RUN cp -r roll_up_circom_tutorial/tokens_transfer circomlib/
RUN rm -rf roll_up_circom_tutorial