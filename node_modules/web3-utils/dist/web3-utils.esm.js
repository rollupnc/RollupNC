import isBoolean from 'lodash/isBoolean';
import isString from 'lodash/isString';
import isNumber from 'lodash/isNumber';
import isNull from 'lodash/isNull';
import numberToBN from 'number-to-bn';
import utf8 from 'utf8';
import Hash from 'eth-lib/lib/hash';
import { unitMap, fromWei, toWei } from 'ethjs-unit';
import isArray from 'lodash/isArray';
import isObject from 'lodash/isObject';
import map from 'lodash/map';
import BN from 'bn.js';
import randomhex from 'randomhex';
export { default as randomHex } from 'randomhex';

const isBN = object => {
  return object instanceof BN || object && object.constructor && object.constructor.name === 'BN';
};
const isBigNumber = object => {
  return object && object.constructor && object.constructor.name === 'BigNumber';
};
const toBN = number => {
  try {
    return numberToBN(number);
  } catch (error) {
    throw new Error(`${error} Given value: "${number}"`);
  }
};
const toTwosComplement = number => {
  return `0x${toBN(number).toTwos(256).toString(16, 64)}`;
};
const isAddress = address => {
  if (!/^(0x)?[0-9a-f]{40}$/i.test(address)) {
    return false;
  } else if (/^(0x|0X)?[0-9a-f]{40}$/.test(address) || /^(0x|0X)?[0-9A-F]{40}$/.test(address)) {
    return true;
  } else {
    return checkAddressChecksum(address);
  }
};
const checkAddressChecksum = address => {
  address = address.replace(/^0x/i, '');
  const addressHash = sha3(address.toLowerCase()).replace(/^0x/i, '');
  for (let i = 0; i < 40; i++) {
    if (parseInt(addressHash[i], 16) > 7 && address[i].toUpperCase() !== address[i] || parseInt(addressHash[i], 16) <= 7 && address[i].toLowerCase() !== address[i]) {
      return false;
    }
  }
  return true;
};
const leftPad = (string, chars, sign) => {
  const hasPrefix = /^0x/i.test(string) || typeof string === 'number';
  string = string.toString(16).replace(/^0x/i, '');
  const padding = chars - string.length + 1 >= 0 ? chars - string.length + 1 : 0;
  return (hasPrefix ? '0x' : '') + new Array(padding).join(sign || '0') + string;
};
const rightPad = (string, chars, sign) => {
  const hasPrefix = /^0x/i.test(string) || typeof string === 'number';
  string = string.toString(16).replace(/^0x/i, '');
  const padding = chars - string.length + 1 >= 0 ? chars - string.length + 1 : 0;
  return (hasPrefix ? '0x' : '') + string + new Array(padding).join(sign || '0');
};
const utf8ToHex = str => {
  str = utf8.encode(str);
  let hex = '';
  str = str.replace(/^(?:\u0000)*/, '');
  str = str.split('').reverse().join('');
  str = str.replace(/^(?:\u0000)*/, '');
  str = str.split('').reverse().join('');
  for (let i = 0; i < str.length; i++) {
    const code = str.charCodeAt(i);
    const n = code.toString(16);
    hex += n.length < 2 ? `0${n}` : n;
  }
  return `0x${hex}`;
};
const hexToUtf8 = hex => {
  if (!isHexStrict(hex)) throw new Error(`The parameter "${hex}" must be a valid HEX string.`);
  let str = '';
  let code = 0;
  hex = hex.replace(/^0x/i, '');
  hex = hex.replace(/^(?:00)*/, '');
  hex = hex.split('').reverse().join('');
  hex = hex.replace(/^(?:00)*/, '');
  hex = hex.split('').reverse().join('');
  const l = hex.length;
  for (let i = 0; i < l; i += 2) {
    code = parseInt(hex.substr(i, 2), 16);
    str += String.fromCharCode(code);
  }
  return utf8.decode(str);
};
const hexToNumber = value => {
  if (!value) {
    return value;
  }
  return toBN(value).toNumber();
};
const hexToNumberString = value => {
  if (!value) return value;
  return toBN(value).toString(10);
};
const numberToHex = value => {
  if (isNull(value) || typeof value === 'undefined') {
    return value;
  }
  if (!isFinite(value) && !isHexStrict(value)) {
    throw new Error(`Given input "${value}" is not a number.`);
  }
  const number = toBN(value);
  const result = number.toString(16);
  return number.lt(new BN(0)) ? `-0x${result.substr(1)}` : `0x${result}`;
};
const bytesToHex = bytes => {
  let hex = [];
  for (let i = 0; i < bytes.length; i++) {
    hex.push((bytes[i] >>> 4).toString(16));
    hex.push((bytes[i] & 0xf).toString(16));
  }
  return `0x${hex.join('').replace(/^0+/, '')}`;
};
const hexToBytes = hex => {
  hex = hex.toString(16);
  if (!isHexStrict(hex)) {
    throw new Error(`Given value "${hex}" is not a valid hex string.`);
  }
  hex = hex.replace(/^0x/i, '');
  hex = hex.length % 2 ? '0' + hex : hex;
  let bytes = [];
  for (let c = 0; c < hex.length; c += 2) {
    bytes.push(parseInt(hex.substr(c, 2), 16));
  }
  return bytes;
};
const toHex = (value, returnType) => {
  if (isAddress(value)) {
    return returnType ? 'address' : `0x${value.toLowerCase().replace(/^0x/i, '')}`;
  }
  if (isBoolean(value)) {
    return returnType ? 'bool' : value ? '0x01' : '0x00';
  }
  if (isObject(value) && !isBigNumber(value) && !isBN(value)) {
    return returnType ? 'string' : utf8ToHex(JSON.stringify(value));
  }
  if (isString(value)) {
    if (value.indexOf('-0x') === 0 || value.indexOf('-0X') === 0) {
      return returnType ? 'int256' : numberToHex(value);
    } else if (value.indexOf('0x') === 0 || value.indexOf('0X') === 0) {
      return returnType ? 'bytes' : value;
    } else if (!isFinite(value)) {
      return returnType ? 'string' : utf8ToHex(value);
    }
  }
  return returnType ? value < 0 ? 'int256' : 'uint256' : numberToHex(value);
};
const isHexStrict = hex => {
  return (isString(hex) || isNumber(hex)) && /^(-)?0x[0-9a-f]*$/i.test(hex);
};
const isHex = hex => {
  return (isString(hex) || isNumber(hex)) && /^(-0x|0x)?[0-9a-f]*$/i.test(hex);
};
const isBloom = bloom => {
  if (!/^(0x)?[0-9a-f]{512}$/i.test(bloom)) {
    return false;
  } else if (/^(0x)?[0-9a-f]{512}$/.test(bloom) || /^(0x)?[0-9A-F]{512}$/.test(bloom)) {
    return true;
  }
  return false;
};
const isTopic = topic => {
  if (!/^(0x)?[0-9a-f]{64}$/i.test(topic)) {
    return false;
  } else if (/^(0x)?[0-9a-f]{64}$/.test(topic) || /^(0x)?[0-9A-F]{64}$/.test(topic)) {
    return true;
  }
  return false;
};
const SHA3_NULL_S = '0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470';
const sha3 = value => {
  if (isHexStrict(value) && /^0x/i.test(value.toString())) {
    value = hexToBytes(value);
  }
  const returnValue = Hash.keccak256(value);
  if (returnValue === SHA3_NULL_S) {
    return null;
  } else {
    return returnValue;
  }
};
sha3._Hash = Hash;
const getSignatureParameters = signature => {
  if (!isHexStrict(signature)) {
    throw new Error(`Given value "${signature}" is not a valid hex string.`);
  }
  const r = signature.slice(0, 66);
  const s = `0x${signature.slice(66, 130)}`;
  let v = `0x${signature.slice(130, 132)}`;
  v = hexToNumber(v);
  if (![27, 28].includes(v)) v += 27;
  return {
    r,
    s,
    v
  };
};

const _elementaryName = name => {
  if (name.startsWith('int[')) {
    return `int256${name.slice(3)}`;
  }
  if (name === 'int') {
    return 'int256';
  }
  if (name.startsWith('uint[')) {
    return `uint256${name.slice(4)}`;
  }
  if (name === 'uint') {
    return 'uint256';
  }
  if (name.startsWith('fixed[')) {
    return `fixed128x128${name.slice(5)}`;
  }
  if (name === 'fixed') {
    return 'fixed128x128';
  }
  if (name.startsWith('ufixed[')) {
    return `ufixed128x128${name.slice(6)}`;
  }
  if (name === 'ufixed') {
    return 'ufixed128x128';
  }
  return name;
};
const _parseTypeN = type => {
  const typesize = /^\D+(\d+).*$/.exec(type);
  return typesize ? parseInt(typesize[1], 10) : null;
};
const _parseTypeNArray = type => {
  const arraySize = /^\D+\d*\[(\d+)\]$/.exec(type);
  return arraySize ? parseInt(arraySize[1], 10) : null;
};
const _parseNumber = arg => {
  const type = typeof arg;
  if (type === 'string') {
    if (isHexStrict(arg)) {
      return new BN(arg.replace(/0x/i, ''), 16);
    } else {
      return new BN(arg, 10);
    }
  } else if (type === 'number') {
    return new BN(arg);
  } else if (isBigNumber(arg)) {
    return new BN(arg.toString(10));
  } else if (isBN(arg)) {
    return arg;
  } else {
    throw new Error(`${arg} is not a number`);
  }
};
const _solidityPack = (type, value, arraySize) => {
  let size, num;
  type = _elementaryName(type);
  if (type === 'bytes') {
    if (value.replace(/^0x/i, '').length % 2 !== 0) {
      throw new Error(`Invalid bytes characters ${value.length}`);
    }
    return value;
  } else if (type === 'string') {
    return utf8ToHex(value);
  } else if (type === 'bool') {
    return value ? '01' : '00';
  } else if (type.startsWith('address')) {
    if (arraySize) {
      size = 64;
    } else {
      size = 40;
    }
    if (!isAddress(value)) {
      throw new Error(`${value} is not a valid address, or the checksum is invalid.`);
    }
    return leftPad(value.toLowerCase(), size);
  }
  size = _parseTypeN(type);
  if (type.startsWith('bytes')) {
    if (!size) {
      throw new Error('bytes[] not yet supported in solidity');
    }
    if (arraySize) {
      size = 32;
    }
    if (size < 1 || size > 32 || size < value.replace(/^0x/i, '').length / 2) {
      throw new Error(`Invalid bytes${size} for ${value}`);
    }
    return rightPad(value, size * 2);
  } else if (type.startsWith('uint')) {
    if (size % 8 || size < 8 || size > 256) {
      throw new Error(`Invalid uint${size} size`);
    }
    num = _parseNumber(value);
    if (num.bitLength() > size) {
      throw new Error(`Supplied uint exceeds width: ${size} vs ${num.bitLength()}`);
    }
    if (num.lt(new BN(0))) {
      throw new Error(`Supplied uint ${num.toString()} is negative`);
    }
    return size ? leftPad(num.toString('hex'), size / 8 * 2) : num;
  } else if (type.startsWith('int')) {
    if (size % 8 || size < 8 || size > 256) {
      throw new Error(`Invalid int${size} size`);
    }
    num = _parseNumber(value);
    if (num.bitLength() > size) {
      throw new Error(`Supplied int exceeds width: ${size} vs ${num.bitLength()}`);
    }
    if (num.lt(new BN(0))) {
      return num.toTwos(size).toString('hex');
    } else {
      return size ? leftPad(num.toString('hex'), size / 8 * 2) : num;
    }
  } else {
    throw new Error(`Unsupported or invalid type: ${type}`);
  }
};
const _processSoliditySha3Args = arg => {
  if (isArray(arg)) {
    throw new Error('Autodetection of array types is not supported.');
  }
  let type;
  let value = '';
  let hexArg, arraySize;
  if (isObject(arg) && (arg.hasOwnProperty('v') || arg.hasOwnProperty('t') || arg.hasOwnProperty('value') || arg.hasOwnProperty('type'))) {
    type = arg.hasOwnProperty('t') ? arg.t : arg.type;
    value = arg.hasOwnProperty('v') ? arg.v : arg.value;
  } else {
    type = toHex(arg, true);
    value = toHex(arg);
    if (!type.startsWith('int') && !type.startsWith('uint')) {
      type = 'bytes';
    }
  }
  if ((type.startsWith('int') || type.startsWith('uint')) && typeof value === 'string' && !/^(-)?0x/i.test(value)) {
    value = new BN(value);
  }
  if (isArray(value)) {
    arraySize = _parseTypeNArray(type);
    if (arraySize && value.length !== arraySize) {
      throw new Error(`${type} is not matching the given array ${JSON.stringify(value)}`);
    } else {
      arraySize = value.length;
    }
  }
  if (isArray(value)) {
    hexArg = value.map(val => {
      return _solidityPack(type, val, arraySize).toString('hex').replace('0x', '');
    });
    return hexArg.join('');
  } else {
    hexArg = _solidityPack(type, value, arraySize);
    return hexArg.toString('hex').replace('0x', '');
  }
};
const soliditySha3 = function () {
  const args = Array.prototype.slice.call(arguments);
  const hexArgs = map(args, _processSoliditySha3Args);
  return sha3(`0x${hexArgs.join('')}`);
};

const jsonInterfaceMethodToString = json => {
  if (isObject(json) && json.name && json.name.indexOf('(') !== -1) {
    return json.name;
  }
  return `${json.name}(${_flattenTypes(false, json.inputs).join(',')})`;
};
const _flattenTypes = (includeTuple, puts) => {
  const types = [];
  puts.forEach(param => {
    if (typeof param.components === 'object') {
      if (param.type.substring(0, 5) !== 'tuple') {
        throw new Error('components found but type is not tuple; report on GitHub');
      }
      let suffix = '';
      const arrayBracket = param.type.indexOf('[');
      if (arrayBracket >= 0) {
        suffix = param.type.substring(arrayBracket);
      }
      const result = _flattenTypes(includeTuple, param.components);
      if (isArray(result) && includeTuple) {
        types.push(`tuple(${result.join(',')})${suffix}`);
      } else if (!includeTuple) {
        types.push(`(${result.join(',')})${suffix}`);
      } else {
        types.push(`(${result})`);
      }
    } else {
      types.push(param.type);
    }
  });
  return types;
};
const hexToAscii = hex => {
  if (!isHexStrict(hex)) throw new Error('The parameter must be a valid HEX string.');
  let str = '';
  let i = 0;
  const l = hex.length;
  if (hex.substring(0, 2) === '0x') {
    i = 2;
  }
  for (; i < l; i += 2) {
    const code = parseInt(hex.substr(i, 2), 16);
    str += String.fromCharCode(code);
  }
  return str;
};
const asciiToHex = (str, length = 32) => {
  let hex = '';
  for (let i = 0; i < str.length; i++) {
    const code = str.charCodeAt(i);
    const n = code.toString(16);
    hex += n.length < 2 ? `0${n}` : n;
  }
  return '0x' + rightPad(hex, length * 2);
};
const getUnitValue = unit => {
  unit = unit ? unit.toLowerCase() : 'ether';
  if (!unitMap[unit]) {
    throw new Error(`This unit "${unit}" doesn't exist, please use the one of the following units${JSON.stringify(unitMap, null, 2)}`);
  }
  return unit;
};
const fromWei$1 = (number, unit) => {
  unit = getUnitValue(unit);
  if (!isBN(number) && !isString(number)) {
    throw new Error('Please pass numbers as strings or BigNumber objects to avoid precision errors.');
  }
  return isBN(number) ? fromWei(number, unit) : fromWei(number, unit).toString(10);
};
const toWei$1 = (number, unit) => {
  unit = getUnitValue(unit);
  if (!isBN(number) && !isString(number)) {
    throw new Error('Please pass numbers as strings or BigNumber objects to avoid precision errors.');
  }
  return isBN(number) ? toWei(number, unit) : toWei(number, unit).toString(10);
};
const toChecksumAddress = address => {
  if (typeof address === 'undefined') return '';
  if (!/^(0x)?[0-9a-f]{40}$/i.test(address)) throw new Error(`Given address "${address}" is not a valid Ethereum address.`);
  address = address.toLowerCase().replace(/^0x/i, '');
  const addressHash = sha3(address).replace(/^0x/i, '');
  let checksumAddress = '0x';
  for (let i = 0; i < address.length; i++) {
    if (parseInt(addressHash[i], 16) > 7) {
      checksumAddress += address[i].toUpperCase();
    } else {
      checksumAddress += address[i];
    }
  }
  return checksumAddress;
};
const keccak256 = sha3;
const sha3$1 = sha3;
const toDecimal = hexToNumber;
const hexToNumber$1 = hexToNumber;
const fromDecimal = numberToHex;
const numberToHex$1 = numberToHex;
const hexToUtf8$1 = hexToUtf8;
const hexToString = hexToUtf8;
const toUtf8 = hexToUtf8;
const stringToHex = utf8ToHex;
const fromUtf8 = utf8ToHex;
const utf8ToHex$1 = utf8ToHex;
const toAscii = hexToAscii;
const fromAscii = asciiToHex;
const padLeft = leftPad;
const padRight = rightPad;
const getSignatureParameters$1 = getSignatureParameters;
const isAddress$1 = isAddress;
const isBN$1 = isBN;
const checkAddressChecksum$1 = checkAddressChecksum;
const toBN$1 = toBN;
const toHex$1 = toHex;
const hexToNumberString$1 = hexToNumberString;
const toTwosComplement$1 = toTwosComplement;
const isHex$1 = isHex;
const isHexStrict$1 = isHexStrict;
const isBloom$1 = isBloom;
const isTopic$1 = isTopic;
const bytesToHex$1 = bytesToHex;
const hexToBytes$1 = hexToBytes;

export { jsonInterfaceMethodToString, hexToAscii, asciiToHex, getUnitValue, fromWei$1 as fromWei, toWei$1 as toWei, toChecksumAddress, keccak256, sha3$1 as sha3, toDecimal, hexToNumber$1 as hexToNumber, fromDecimal, numberToHex$1 as numberToHex, hexToUtf8$1 as hexToUtf8, hexToString, toUtf8, stringToHex, fromUtf8, utf8ToHex$1 as utf8ToHex, toAscii, fromAscii, padLeft, padRight, getSignatureParameters$1 as getSignatureParameters, isAddress$1 as isAddress, isBN$1 as isBN, checkAddressChecksum$1 as checkAddressChecksum, toBN$1 as toBN, toHex$1 as toHex, hexToNumberString$1 as hexToNumberString, toTwosComplement$1 as toTwosComplement, isHex$1 as isHex, isHexStrict$1 as isHexStrict, isBloom$1 as isBloom, isTopic$1 as isTopic, bytesToHex$1 as bytesToHex, hexToBytes$1 as hexToBytes, soliditySha3 };
