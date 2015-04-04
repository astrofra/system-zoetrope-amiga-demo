import os
import string
import codecs
import ast
import math
from vector3 import Vector3

filename_out			=	"../../Assets/cosine_table"
table_size				=	512
fixed_point_precision 	=	512

def dumpCosine(_cosine_func, display_name, f):
	f.write('const int ' + display_name + '[] =' + '\n')
	f.write('{' + '\n')

	# _str_out = '\t'
	for angle in range(0,table_size):
		_cos = int(_cosine_func(angle * math.pi / (table_size / 2.0)) * fixed_point_precision)
		_str_out = str(_cos) + ','
		f.write(_str_out + '\n')
		# if angle%10 == 9:
		# 	f.write(_str_out + '\n')
		# 	_str_out = '\t'

	f.write('};' + '\n')

def  main():
	##	Creates the header
	f = codecs.open(filename_out + '.h', 'w')

	f.write('#define COSINE_TABLE_LEN ' + str(table_size) + '\n')
	f.write('\n')

	f.write('extern const int tcos[COSINE_TABLE_LEN];' + '\n')
	f.write('extern const int tsin[COSINE_TABLE_LEN];' + '\n')

	f.close()

	##	Creates the C file
	f = codecs.open(filename_out + '.c', 'w')

	dumpCosine(_cosine_func = math.cos, display_name = 'tcos', f = f)
	f.write('\n')
	dumpCosine(_cosine_func = math.sin, display_name = 'tsin', f = f)

	f.close()

main()