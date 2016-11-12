import argparse
import math
from enum import Enum

# =================================================================================

intSize = 0
fracSize = 0

# =================================================================================

class OperationEnum(Enum):
    NoOp = 0
    Sine = 1
    Cosine = 2
    CosineSine = 3
    
    @staticmethod
    def fromstring(string):
        if string == 'none':
            return OperationEnum.NoOp
        elif string == 'sine':
            return OperationEnum.Sine
        elif string == 'cosine':
            return OperationEnum.Cosine
        elif string == 'cosine-sine':
            return OperationEnum.CosineSine
        else:
            raise ValueError("String {0} cannot be converted to OperationEnum".format(string))        

# =================================================================================


def FixedPointFormat(string):
    global intSize
    global fracSize
    splitFormat = string.split('.', 2)
    intSize = int(splitFormat[0])
    fracSize = int(splitFormat[1]) 

def FloatList(string):
    return [float(str) for str in string.split(',')]

# =================================================================================
    
def FloatToFixed(floatNumber):
    if floatNumber >= pow(2,intSize):
        print('INPUT ERROR : {} overflows a fixed point of format {}.{}'.format(floatNumber, intSize, fracSize))
    fixedNumber = round(floatNumber * pow(2, fracSize))
    return (fixedNumber if fixedNumber >= 0 else TwosComplement(fixedNumber))
    
def TwosComplement(number):
    return number + (1 << (intSize + fracSize))

# =================================================================================

def CalcVal1(float, multiplier):
    if operation == OperationEnum.Sine:
        curangle = math.radians(float)
        return FloatToFixed(math.sin(curangle) * curmultiplier)
    elif operation == OperationEnum.Cosine or operation == OperationEnum.CosineSine:
        curangle = math.radians(float)
        return FloatToFixed(math.cos(curangle) * curmultiplier)
    else:
        return FloatToFixed(float * multiplier)

def CalcVal2(float, multiplier):
    if (operation == OperationEnum.CosineSine):
        curangle = math.radians(float)
        return FloatToFixed(math.sin(curangle) * curmultiplier)        
    else:
        return 0.0

# =================================================================================
parser = argparse.ArgumentParser(description="A tool to compute cos/sin tables in fixed point format.")
parser.add_argument("-operation", choices=['none','sine','cosine','cosine-sine'], default='none', help='The operation to do on the float inputs before the conversion. none = x, sine = sin(x), cosine = cos(x), cosine-sine = cos(x), sin(x)')
parser.add_argument('-precision', type=FixedPointFormat, default=FixedPointFormat('4.4'), help='Specify the precision of the fixed point conversion. Default is 4.4')
parser.add_argument('-multipliers', type=FloatList, default=[float(1)], help='Comma-separated list of values to multiply the specified floats before the conversion. If there is an operation then the multiplication will be done on it\'s result.')

group = parser.add_mutually_exclusive_group()
group.add_argument('-labelname', default='anglegrinder_values')
group.add_argument('-nolabels', action="store_true")

parser.add_argument('floatlist', type=FloatList, help='Comma-separated list of floats to convert to fixed point.')
parser.add_argument('outfile', type=argparse.FileType('w'), help='File in which the converted floats will be written to (in NESASM format)')
args = parser.parse_args()

operation = OperationEnum.fromstring(args.operation)
dataformat = '${val1:02x}'

if operation == OperationEnum.Sine:
    commentformat = '{multiplier}sin({inputval}) in fixed {fixedint}.{fixedfrac}'
elif operation == OperationEnum.Cosine:
    commentformat = '{multiplier}cos({inputval}) in fixed {fixedint}.{fixedfrac}'
elif operation == OperationEnum.CosineSine:
    commentformat = '{multiplier}cos({inputval}), {multiplier}sin({inputval}) in fixed {fixedint}.{fixedfrac}'
    dataformat = '${val1:02x},${val2:02x}'
else:
    commentformat = '{multiplier}{inputval} in fixed {fixedint}.{fixedfrac}'

if args.nolabels == False:
    args.outfile.write(args.labelname + ':\n')
    
for curmultiplier in args.multipliers:
    for curfloat in args.floatlist:
        val1 = CalcVal1(curfloat, curmultiplier)
        val2 = CalcVal2(curfloat, curmultiplier)
    
        multiplierstr = ''
        if (curmultiplier != 1.0):
            multiplierstr = '{0} * '.format(curmultiplier) 
        commentline = commentformat.format(multiplier=multiplierstr, inputval=curfloat, fixedint=intSize, fixedfrac=fracSize)
        dataline = dataformat.format(val1=val1, val2=val2)
        linetowrite = '   .db {data}   ; {comment}\n'.format(data=dataline, comment=commentline)
        args.outfile.write(linetowrite)