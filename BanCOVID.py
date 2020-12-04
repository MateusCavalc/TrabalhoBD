#!/usr/bin/python3

import sqlite3
from os import system

class Bancovid19():
	def __init__(self, database):
		self.conn = sqlite3.connect(database)
		self.c = self.conn.cursor()
		sql = "PRAGMA foreign_keys = ON" # Enable foreign_keys constraint
		self.c.execute(sql)

	def CloseConnections(self):
		self.c.close()
		self.conn.close()

	def PrintTable(self, tableName):
		fields, rows, max_len = self.GetTableContent(tableName)
		linhas = []

		print('|', end='')
		for index, field in enumerate(fields):
			linha = ""
			max_len = 0
			for row in rows:
				if max_len == 0: max_len = len(str(row[index]))
				elif len(str(row[index])) > max_len:	max_len = len(str(row[index]))

			if len(field) > max_len: max_len = len(field)

			while len(linha) < max_len: linha = linha + '-'
			linhas.append(linha)

			print(("{:" + str(len(linha)) + "s}|").format(field), end='')
		print("\n|", end='')
		for linha in linhas:
			print("{0}|".format(linha), end='')
		for row in rows:
			print("\n|", end='')
			for item,linha in zip(row,linhas):
				print(("{:" + str(len(linha)) + "s}|").format(str(item)), end='')
		print("\n|", end='')
		for linha in linhas:
			print("{0}|".format(linha), end='')
		print("\n\n", end='')

	def GetViewNames(self):
		sql = "SELECT name FROM sqlite_master WHERE type = 'view'"
		return self.c.execute(sql).fetchall()

	def GetTableNames(self):
		sql = "SELECT name FROM sqlite_master WHERE type = 'table' and name != 'sqlite_sequence'"
		return self.c.execute(sql).fetchall()
 
	def GetTableInfo(self, tableName):
		sql = "PRAGMA TABLE_INFO(" +  tableName + ")"
		table_info = self.c.execute(sql).fetchall()
		table_fields = []
		for info in table_info:
			table_fields.append((info[1], info[2], info[5]))
		
		sql = "PRAGMA FOREIGN_KEY_LIST(" +  tableName + ")"
		table_pks = self.c.execute(sql).fetchall()
		pks_info = []
		for table_pk in table_pks:
			pks_info.append((table_pk[2], table_pk[3], table_pk[4]))

		return table_fields, pks_info

	def GetTableContent(self, tableName):
		table_infos, table_pks = self.GetTableInfo(tableName)
		table_fields = []
		for info in table_infos:
			table_fields.append(info[0])
		
		sql = "SELECT * FROM " +  tableName
		rows = self.c.execute(sql).fetchall()
		max_of_rows = []
		max_of_rows.append(len(max(table_fields, key=len)))
		for row in rows:
			row = list(map(str,row))
			max_of_rows.append(len(max(row, key=len)))

		max_len = max(max_of_rows)

		return table_fields, rows, max_len

	def GetExistingPKS(self, pkInfo):
		sql = "SELECT " + pkInfo[2] + " FROM " +  pkInfo[1]
		fkValues = []
		for fk_info in self.c.execute(sql).fetchall():
			fkValues.append(fk_info[0])

		return fkValues

	def addOnTable(self, tableName, fields, newValues):
		sql = "INSERT INTO " + tableName + " ("
		for i in range(len(fields)):
			sql = sql + fields[i][0]
			if(i < len(fields) - 1):
				sql = sql + ","

		sql = sql + ") VALUES ("
		for i in range(len(newValues)):
			sql = sql + newValues[i]
			if(i < len(newValues) - 1):
				sql = sql + ","

		sql = sql + ")"

		self.c.execute(sql)
		self.conn.commit()

	def RemovefromTable(self, tableName, pkToRemove, toRemove):
		sql = "DELETE FROM " + tableName + " WHERE " + pkToRemove + "='" + toRemove + "'"

		self.c.execute(sql).fetchall()
		self.conn.commit()
		return self.c.rowcount

	def EditInTable(self, tableName, pkToEdit, whereToEdit, fieldsToEdit, newValues):
		sql = "UPDATE " + tableName + " SET "
		for i in range(len(fieldsToEdit)):
			sql = sql + fieldsToEdit[i] + "=" + newValues[i] + ""
			if(i < len(fieldsToEdit) - 1):
				sql = sql + ","

		sql = sql + " WHERE " + pkToEdit + "='" + whereToEdit + "'"

		self.c.execute(sql)
		self.conn.commit()
		return self.c.rowcount

def containsPK(field, pks):
	for index, pk in enumerate(pks):
		if pk[0] == field: return pk

	return None

def CRUD(banco):				# --- CRUD --- 
	while True:
		system("clear")
		print("# CRUD #")
		print("\n1) Ver registros\n2) Adicionar registro\n3) Remover registro\n4) Editar registro\n5) Voltar\n")
		opt = input("> ")
		if opt == '1':            #--- Ver ---
			system("clear")
			tables = banco.GetTableNames()
			print("# REGISTROS #\n")
			it = 1
			table_names = []
			for table in tables:
				print(str(it) + ") " + table[0])
				table_names.append(table[0])
				it = it + 1

			opt2 = input("\n> ")
			system("clear")
			print("# Registros de '" + table_names[int(opt2)-1] + "' #\n")
			banco.PrintTable(table_names[int(opt2)-1])
			input()

		elif opt == '2':            #-- Adicionar ---
			system("clear")
			tables = banco.GetTableNames()
			print("# ADICIONAR EM #\n")             #-- Adicionar ---
			it = 1
			table_names = []
			for table in tables:
				print(str(it) + ") " + table[0])
				table_names.append(table[0])
				it = it + 1

			opt2 = input("\n> ")            #-- Adicionar em: ---
			fields, pks = banco.GetTableInfo(table_names[int(opt2)-1])
			inputs = []
			for field in fields:
				system("clear")
				print("# NOVO REGISTRO EM '" + table_names[int(opt2)-1] + "' #")
				found = containsPK(field[0], pks)
				if found == None: # não é fk
					newValue = input("|- " + field[0] + " [" + field[1] + "] : ")
				else:
					print()
					banco.PrintTable(found[1])
					newValue = input("|- " + field[0] + " ['" + found[2] + "' -> " + field[1] + "] : ")

				if newValue != "NULL":	newValue = "'" + newValue + "'"

				inputs.append(newValue)
			
			try:
				banco.addOnTable(table_names[int(opt2)-1], fields, inputs)
				input("> Registro adicionado\t\t(press enter)")
			except Exception as e:
				print(e)
				input("> Registro não pôde ser adicionado\t\t(press enter)")

		elif opt == '3':            #-- Remover ---
			system("clear")
			tables = banco.GetTableNames()
			print("# REMOVER EM #\n")
			it = 1
			table_names = []
			for table in tables:
				print(str(it) + ") " + table[0])
				table_names.append(table[0])
				it = it + 1

			opt2 = input("\n> ")            #-- Remover em: ---
			system("clear")
			fields, pks = banco.GetTableInfo(table_names[int(opt2)-1])
			print("# REMOVER REGISTRO EM '" + table_names[int(opt2)-1] + "' #")
			banco.PrintTable(table_names[int(opt2)-1])
			for field in fields:
				if(field[2] == 1):
					pkToRemove = field[0]
					toRemove = input("|- Informar " + pkToRemove + " do registro para remover: ")
					break
				
			try:
				if banco.RemovefromTable(table_names[int(opt2)-1], pkToRemove, toRemove) > 0:
					input("> Registro removido (" + pkToRemove + ": '" + toRemove + "')\t\t(press enter)")
				else:
					input("> Não existe registro com " + pkToRemove + ": '" + toRemove + "'\t\t(press enter)")
			except Exception as e:
				print(e)
				input("> Registro não pôde ser removido\t\t(press enter)")

		elif opt == '4':
			system("clear")
			tables = banco.GetTableNames()
			print("# EDITAR EM #\n")
			it = 1
			table_names = []
			for table in tables:
				print(str(it) + ") " + table[0])
				table_names.append(table[0])
				it = it + 1

			opt2 = input("\n> ")            #-- Editar em: ---
			system("clear")
			fields, pks = banco.GetTableInfo(table_names[int(opt2)-1])
			print("# EDITAR REGISTRO EM '" + table_names[int(opt2)-1] + "' #")
			banco.PrintTable(table_names[int(opt2)-1])
			for field in fields:
				if(field[2] == 1):
					pkToEdit = field[0]
					whereToEdit = input("|- Informar " + pkToEdit + " do registro para editar: ")
					whatToEdit = input("|- Informar campos do registro para editar (separados por vírgula): ")
					break
				
			fieldsToEdit = whatToEdit.split(',')

			# Verifica se os campos fornecidos para edição existem no banco
			found = False
			for fieldToEdit in fieldsToEdit:
				found = False
				for field in fields:
					if field[0] == fieldToEdit:
						found = True

				if not found:
					print("> Não existe o campo '" + fieldToEdit + "' para editar\t\t(press enter)")
					break

			if found:
				newValues = []
				for fieldToEdit in fieldsToEdit:
					for field in fields:
						if field[0] == fieldToEdit:
							newValue = input("|- " + field[0] + " [" + field[1] + "] : ")
							if newValue != "NULL":	newValue = "'" + newValue + "'"
							newValues.append(newValue)
				
				try:
					if banco.EditInTable(table_names[int(opt2)-1], pkToEdit, whereToEdit, fieldsToEdit, newValues) > 0:
						input("> Registro editado (" + pkToEdit + ": '" + whereToEdit + "')\t\t(press enter)")
					else:
						input("> Não existe registro com " + pkToEdit + ": '" + whereToEdit + "'\t\t(press enter)")
				except Exception as e:
					print(e)
					input("> Registro não pôde ser editado\t\t(press enter)")

		elif opt == '5':
			break

def GerenciarPacientes(banco):					# --- Gerenciar Pacientes --- 
	while True:
		system("clear")
		print("# Gerenciar pacientes #")
		print("\n1) Ver pacientes\n2) Adicionar paciente\n3) Editar paciente\n4) Voltar\n")
		opt = input("> ")
		if opt == '1':
			system("clear")
			print("# Ver pacientes #\n")
			banco.PrintTable('Pacientes_Info')
			input('\tvoltar\t\t(press enter)')

		elif opt == '2':
			system("clear")
			print("# NOVO PACIENTE #")
			fields, pks = banco.GetTableInfo('Paciente')
			inputs = []
			for field in fields:
				if field[0] == 'entrada':	newValue = "DATE('now')"
				elif field[0] == 'saida':	newValue = "NULL"
				else:
					found = containsPK(field[0], pks)
					if found == None: # não é fk
						newValue = input("|- " + field[0] + " [" + field[1] + "] : ")
					else:
						print()
						banco.PrintTable(found[1])
						newValue = input("|- " + field[0] + " ['" + found[2] + "' -> " + field[1] + "] (Para NULL, deixar em branco) : ")
						
					if newValue == '':	newValue = "NULL"
					else:	newValue = "'" + newValue + "'"
			
				inputs.append(newValue)
			
			try:
				banco.addOnTable("Paciente", fields, inputs)
				input("> Paciente adicionado\t\t(press enter)")
			except Exception as e:
				print(e)
				input("> Paciente não pôde ser adicionado\t\t(press enter)")

		elif opt == '3':
			system("clear")
			print("# EDITAR PACIENTE #")
			banco.PrintTable("Paciente")
			fieldsToEdit = []
			newValues = []
			cpfToEdit = input("\n|- Informar paciente (cpf): ")
			novoEstado = input("\n|- Novo estado: ")
			fieldsToEdit.append("estado")
			newValues.append("'" + novoEstado + "'")
			if novoEstado == "Obito" or novoEstado == "Alta":
				fieldsToEdit.append("saida")
				newValues.append("DATE('now')")

			try:
				if banco.EditInTable("Paciente", "pac_cpf", cpfToEdit, fieldsToEdit, newValues) > 0:
					input("> Paciente editado (cpf: '" + cpfToEdit + "')\t\t(press enter)")
				else:
					input("> Não existe registro com cpf: '" + cpfToEdit + "'\t\t(press enter)")
			except Exception as e:
				print(e)
				input("> Registro não pôde ser editado\t\t(press enter)")

		elif opt == '4':
			break

def main():
	banco = Bancovid19('database.db')
	while True:
		system("clear")
		print("# BANCO(VID-19) DE DADOS #")
		print("\n1) Visualização de Dados (VIEWS)\n2) Gerenciar pacientes\n3) CRUD\n4) Sair\n")
		opt = input("> ")
		if opt == '1': 
			system("clear")
			views = banco.GetViewNames()
			print("# Dados (VIEWS) #\n")
			it = 1
			view_names = []
			for view in views:
				print(str(it) + ") " + view[0])
				view_names.append(view[0])
				it = it + 1

			opt2 = input("\n> ")
			system("clear")
			print("# Registros de '" + view_names[int(opt2)-1] + "' #\n")
			banco.PrintTable(view_names[int(opt2)-1])
			input()

		elif opt == '2':
			GerenciarPacientes(banco)

		elif opt == '3':
			CRUD(banco)

		elif opt == '4':
			break

	banco.CloseConnections()

if __name__ == "__main__":
	main()