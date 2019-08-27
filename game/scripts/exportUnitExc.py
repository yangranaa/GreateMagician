import xlrd
import xlwt

def genTypeList():
	luaFilePath = r'D:\SteamLibrary\steamapps\common\dota 2 beta\game\dota_addons\greatmagician\scripts\vscripts\spawner\\'

	workbook = xlrd.open_workbook(r'D:\SteamLibrary\steamapps\common\dota 2 beta\game\dota_addons\greatmagician_creep.xlsx')
	for sheetName in workbook.sheet_names():
		genSheet = workbook.sheet_by_name(sheetName)
		startGenCol = int(genSheet.cell(0,0).value)
		keyRow = 3
		luaFiles = {}
		for rowIdx in range(genSheet.nrows):
			if rowIdx > keyRow:
				genStrs = []
				unitName = genSheet.cell(rowIdx, genSheet.ncols - 1).value
				genStrs.append("\t" + "},\n")
				for k,v in enumerate(genSheet.row_values(rowIdx)):
					if k >= startGenCol:
						keyName = str(genSheet.cell(keyRow,k).value)
						keyValue = str(v)
						if keyName == "unitName":
							keyValue = "\"" + keyValue + "\""
						genStr = "\t\t" + keyName + " = " + keyValue + ",\n"
						genStrs.append(genStr)
				genStrs.append("\t" + unitName + " = {\n")
				

				filename = genSheet.cell(rowIdx, startGenCol - 1).value
				if luaFiles.get(filename, 0) == 0:
					with open(luaFilePath + filename + '.lua', 'r') as f:
						luaFiles[filename] = f.readlines()
						f.close()
						startIdx = 0
						endIdx = 0
						for lineIdx, line in enumerate(luaFiles[filename]):
							if line.find('-- genStart') != -1:
								startIdx = lineIdx
							if line.find('-- genEnd') != -1:
								endIdx = lineIdx
								break
						del luaFiles[filename][startIdx + 1: endIdx]
						
						for genLine in genStrs:
							luaFiles[filename].insert(startIdx + 1, genLine)
				else:
					startIdx = 0
					for lineIdx, line in enumerate(luaFiles[filename]):
						if line.find('-- genStart') != -1:
							startIdx = lineIdx
							break
					for genLine in genStrs:
						luaFiles[filename].insert(startIdx + 1, genLine)

		for filename in luaFiles.keys():
			with open(luaFilePath + filename + '.lua', 'w') as f:
				f.writelines(luaFiles[filename])
				f.close()

		print "gen type list sucess",genSheet.name

if __name__ == '__main__':
	genTypeList()