FROM node:11


WORKDIR /usr/src/roll_up

RUN npm install -g circom
RUN npm install -g snarkjs

RUN git clone https://github.com/iden3/circomlib
RUN cd circomlib;npm install;cd ..

# RUN git clone https://github.com/GuthL/roll_up_circom_tutorial
RUN git clone -b withdraw https://github.com/barryWhiteHat/RollupNC/
RUN cp -r RollupNC/leaf_update circomlib/
RUN cp -r RollupNC/signature_verification circomlib/
RUN cp -r RollupNC/tokens_transfer circomlib/
RUN rm -rf RollupNC