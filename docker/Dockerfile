FROM node:11


WORKDIR /usr/src/roll_up

RUN npm install -g circom
RUN npm install -g snarkjs

RUN git clone https://github.com/iden3/circomlib rollupNC
RUN cd circomlib;npm install;cd ..

RUN git clone -b transfer https://github.com/barryWhiteHat/RollupNC/
RUN cp -r RollupNC/withdraw rollupNC/
RUN cp -r RollupNC/tokens_transfer rollupNC/
RUN rm -rf RollupNC