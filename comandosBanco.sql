DROP TABLE IF EXISTS Dependente;
DROP TABLE IF EXISTS Estado;
DROP TABLE IF EXISTS Orçamento;
DROP TABLE IF EXISTS Hospital;
DROP TABLE IF EXISTS Equipamentos;
DROP TABLE IF EXISTS Ala_medica;
DROP TABLE IF EXISTS Funcionario;
DROP TABLE IF EXISTS Email;
DROP TABLE IF EXISTS Profissao;
DROP TABLE IF EXISTS Paciente;
DROP TABLE IF EXISTS Telefone;
DROP TABLE IF EXISTS Dados_covid;

DROP TABLE IF EXISTS DependenciaFunc;
DROP TABLE IF EXISTS DependenciaPac;

-- TABELAS

-- -----------------------------------------------------
-- Table `mydb`.`Dependente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Dependente (
  `dep_cpf` VARCHAR(20) PRIMARY KEY,
  `depNome` VARCHAR(45) NOT NULL);

-- -----------------------------------------------------
-- Table `mydb`.`Estado`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Estado (
  `sigla` VARCHAR(2) PRIMARY KEY,
  `popul` INT NOT NULL,
  `regiao` VARCHAR(45) NOT NULL);

-- -----------------------------------------------------
-- Table `mydb`.`Orçamento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Orçamento (
  `idOrçamento` INTEGER PRIMARY KEY AUTOINCREMENT,
  `to_equip` DOUBLE NOT NULL,
  `to_manut` DOUBLE NOT NULL,
  `to_salario` DOUBLE NOT NULL);

-- -----------------------------------------------------
-- Table `mydb`.`Hospital`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Hospital (
  `cep` VARCHAR(10) PRIMARY KEY,
  `Estado` VARCHAR(2) NOT NULL,
  `Orçamento` INT NOT NULL,
  `hNome` VARCHAR(45) NOT NULL,
  `porte` VARCHAR(45) NOT NULL,
  FOREIGN KEY (`Estado`) REFERENCES Estado (`sigla`),
  FOREIGN KEY (`Orçamento`) REFERENCES Orçamento (`idOrçamento`));

-- -----------------------------------------------------
-- Table `mydb`.`Equipamentos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Equipamentos (
  `idEquipamentos` INTEGER PRIMARY KEY AUTOINCREMENT,
  `masc_disp` INT NOT NULL,
  `resp_disp` INT NOT NULL,
  `maca_disp` INT NOT NULL);

-- -----------------------------------------------------
-- Table `mydb`.`Ala_medica`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Ala_medica (
  `alaNome` VARCHAR(45) PRIMARY KEY,
  `Hospital` VARCHAR(10) NOT NULL,
  `Equipamentos` INT NOT NULL,
  `n_pacientes` INT NOT NULL,
  `n_leitos` INT NOT NULL,
  FOREIGN KEY (`Hospital`) REFERENCES Hospital (`cep`),
  FOREIGN KEY (`Equipamentos`) REFERENCES Equipamentos (`idEquipamentos`));


-- -----------------------------------------------------
-- Table `mydb`.`Funcionario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Funcionario (
  `n_registro` INTEGER PRIMARY KEY AUTOINCREMENT,
  `Ala_medica` VARCHAR(45) NOT NULL,
  `fNome` VARCHAR(45) NOT NULL,
  `data_admissao` DATE NOT NULL,
  FOREIGN KEY (`Ala_medica`) REFERENCES Ala_medica (`alaNome`));


-- -----------------------------------------------------
-- Table `mydb`.`email`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Email (
  `endereco` VARCHAR(45) PRIMARY KEY,
  `Funcionario` INT NOT NULL,
  FOREIGN KEY (`Funcionario`) REFERENCES Funcionario (`n_registro`));

-- -----------------------------------------------------
-- Table `mydb`.`Profissao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Profissao (
  `id_prof` INTEGER PRIMARY KEY AUTOINCREMENT,
  `profNome` VARCHAR(45) NOT NULL,
  `area_atua` VARCHAR(45) NOT NULL,
  `carga_hora` INT NOT NULL,
  `risco_expo` VARCHAR(10) NOT NULL);

-- -----------------------------------------------------
-- Table `mydb`.`Paciente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Paciente (
  `pac_cpf` VARCHAR(20) PRIMARY KEY,
  `Profissao` INTEGER NOT NULL,
  `Ala_medica` VARCHAR(45) NOT NULL,
  `pacNome` VARCHAR(45) NOT NULL,
  `estado` VARCHAR(20) NOT NULL,
  `sexo` VARCHAR(1) NOT NULL,
  `data_nasc` DATE NOT NULL,
  `entrada` DATE NOT NULL,
  `saida` DATE NULL,
  FOREIGN KEY (`Profissao`) REFERENCES Profissao (`id_prof`),
  FOREIGN KEY (`Ala_medica`) REFERENCES Ala_medica (`alaNome`));

-- -----------------------------------------------------
-- Table `mydb`.`telefone`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Telefone (
  `num_tel` VARCHAR(11) PRIMARY KEY,
  `Dependente` VARCHAR(20) NOT NULL,
  FOREIGN KEY (`Dependente`) REFERENCES Dependente (`cpf`));

-- -----------------------------------------------------
-- Table `mydb`.`Dados_covid`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS Dados_covid (
  `idDados_covid` INTEGER PRIMARY KEY AUTOINCREMENT,
  `Estado` VARCHAR(2) NOT NULL,
  `last_att` DATETIME NOT NULL,
  `num_casos` INT NOT NULL,
  `num_mortes` INT NOT NULL,
  `num_recup` INT NOT NULL,
  FOREIGN KEY (`Estado`) REFERENCES Estado (`sigla`));
-- -----------------------------------------------------
-- Table `mydb`.`DependenciaFunc`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS DependenciaFunc (
  `Dependente` VARCHAR(20) NOT NULL,
  `Funcionario` INTEGER NOT NULL,
  `parentesco` VARCHAR(20) NOT NULL,
  FOREIGN KEY (`Funcionario`) REFERENCES Funcionario (`n_registro`)
  PRIMARY KEY (Dependente, Funcionario));
-- -----------------------------------------------------
-- Table `mydb`.`DependenciaPac`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS DependenciaPac (
  `Dependente` VARCHAR(20) NOT NULL,
  `Paciente` VARCHAR(20) NOT NULL,
  `parentesco` VARCHAR(20) NOT NULL,
  FOREIGN KEY (`Paciente`) REFERENCES Paciente (`pac_cpf`)
  PRIMARY KEY (Dependente, Paciente));
-- ----------------------------------------------------------------------------------------------------------

-- VIEWS

DROP VIEW IF EXISTS Hospitais_Info;

CREATE VIEW Hospitais_Info AS
SELECT hNome, porte, to_equip, to_manut, to_salario, sigla, regiao 
FROM Hospital, Orçamento, Estado 
WHERE 
Hospital.Orçamento = Orçamento.idOrçamento AND
Hospital.Estado = Estado.sigla;

--SELECT * FROM Hospitais_Info;

-- AR = π hNome,porte,to_equip,to_manut,to_salario,sigla,regiao( 
--      σ Hospital.Orçamento=Orçamento.idOrçamento and Hospital.Estado=Estado.sigla
--      (( Hospital ⨯ Orçamento ) ⨯ Estado ))

------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS Alas_Info;

CREATE VIEW Alas_Info AS
SELECT alaNome, n_pacientes, n_leitos, masc_disp, resp_disp, maca_disp, hNome, porte
FROM Ala_medica, Equipamentos, Hospital
WHERE
Ala_medica.Equipamentos = Equipamentos.idEquipamentos AND
Ala_medica.Hospital = Hospital.cep;

--SELECT * FROM Alas_Info;

-- AR = π alaNome,n_pacientes,n_leitos,masc_disp,resp_disp,maca_disp,hNome,porte(
--      σ Ala_medica.Equipamentos=Equipamentos.idEquipamentos and Ala_medica.Hospital=Hospital.cep
--      (( Ala_medica ⨯ Equipamentos ) ⨯ Hospital ))

------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS Pacientes_Info;    

CREATE VIEW Pacientes_Info AS
SELECT pac_cpf, pacNome, profNome, Ala_medica, estado, sexo, data_nasc, entrada, saida
FROM Paciente, Profissao, Ala_medica
WHERE
Paciente.Profissao = Profissao.id_prof AND
Paciente.Ala_medica = Ala_medica.alaNome;

--SELECT * FROM Pacientes_Info;

-- AR = π pac_cpf,pacNome,profNome,Ala_medica,estado,sexo,data_nasc,entrada,saida(
--      σ Profissao.id_prof=Paciente.Profissao and Paciente.Ala_medica=Ala_medica.alaNome
--      (( Paciente x Profissao ) ⨯ Ala_medica ))

------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS Dependencias_func; 

CREATE VIEW Dependencias_func AS
SELECT fNome, depNome, parentesco
FROM Funcionario, Dependente, DependenciaFunc
WHERE
DependenciaFunc.Funcionario = Funcionario.n_registro AND
DependenciaFunc.Dependente = Dependente.dep_cpf;

--SELECT * FROM Dependencias_func;

-- AR = π fNome,depNome,parentesco(
--      σ DependenciaFunc.Funcionario=Funcionario.n_registro and DependenciaFunc.Dependente=Dependente.dep_cpf
--      (( DependenciaFunc ⨯ Funcionario ) ⨯ Dependente ))

------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS Dependencias_pac; 

CREATE VIEW Dependencias_pac AS
SELECT pacNome, depNome, parentesco
FROM Paciente, Dependente, DependenciaPac
WHERE
DependenciaPac.Paciente = Paciente.pac_cpf AND
DependenciaPac.Dependente = Dependente.dep_cpf;

--SELECT * FROM Dependencias_pac;

-- AR = π pacNome,depNome,parentesco(
--      σ DependenciaPac.Paciente=Paciente.pac_cpf and DependenciaPac.Dependente=Dependente.dep_cpf
--      (( DependenciaPac ⨯ Paciente ) ⨯ Dependente ))

------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS Covid_Info;    

CREATE VIEW Covid_Info AS
SELECT sigla, popul, (SELECT COUNT(*) FROM Hospital WHERE Estado = sigla) as numHospitais, num_casos, num_mortes, num_recup, last_att
FROM Dados_covid, Estado
WHERE Dados_covid.Estado = Estado.sigla;

--SELECT * FROM Covid_Info;

------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS Funcionarios_Info;    

CREATE VIEW Funcionarios_Info AS
SELECT n_registro, fNome, alaNome
FROM Funcionario, Ala_medica
WHERE
Funcionario.Ala_medica = Ala_medica.alaNome;

--SELECT * FROM Funcionarios_Info;

-- AR = π n_registro, fNome, alaNome( σ Ala_medica.alaNome = Funcionario.Ala_medica ( Funcionario x Ala_medica ) )

------------------------------------------------------------------------------------------------------------------------

DROP VIEW IF EXISTS Profissao_Info;    

CREATE VIEW Profissao_Info AS
SELECT profNome, risco_expo, (SELECT COUNT(*) FROM Paciente WHERE Paciente.Profissao = Profissao.id_prof) as num_casos
FROM Profissao;

--SELECT * FROM Profissao_Info;

-- AR = π n_registro, fNome, alaNome( σ Ala_medica.alaNome = Funcionario.Ala_medica ( Funcionario x Ala_medica ) )

------------------------------------------------------------------------------------------------------------------------

-- TRIGGERS

DROP TRIGGER IF EXISTS addPaciente;

CREATE TRIGGER addPaciente AFTER INSERT 
ON Paciente
BEGIN
    -- Coloca o paciente na ala médica
    UPDATE Ala_medica SET n_pacientes = n_pacientes + 1
    WHERE alaNome = new.Ala_medica;

    -- Utiliza um respirador e maca
    UPDATE Equipamentos SET resp_disp = resp_disp - 1, maca_disp = maca_disp - 1
    WHERE idEquipamentos = (SELECT Equipamentos FROM Ala_medica WHERE alaNome = new.Ala_medica);

    -- Atualiza o Banco Covid -> +1 numero de casos
    UPDATE Dados_covid SET num_casos = num_casos + 1, last_att = DATETIME('now', 'localtime')
    WHERE Estado = (
        SELECT sigla 
        FROM Ala_medica, Hospital, Estado
        WHERE
        new.Ala_medica = Ala_medica.alaNome AND
        Ala_medica.Hospital = Hospital.cep AND
        Hospital.Estado = Estado.sigla
    );
END;

------------------------------------------------------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS altaPaciente;

CREATE TRIGGER altaPaciente AFTER UPDATE 
ON Paciente
WHEN new.estado = 'Alta'
BEGIN
    -- Remove o paciente da ala médica
    UPDATE Ala_medica SET n_pacientes = n_pacientes - 1
    WHERE alaNome = (SELECT new.Ala_medica);

    -- Retorna um respirador e maca
    UPDATE Equipamentos SET resp_disp = resp_disp + 1, maca_disp = maca_disp + 1
    WHERE idEquipamentos = (SELECT Equipamentos FROM Ala_medica WHERE alaNome = new.Ala_medica);

    -- Atualiza o Banco Covid -> +1 numero de recuperados
    UPDATE Dados_covid SET num_recup = num_recup + 1, last_att = DATETIME('now', 'localtime')
    WHERE Estado = (
        SELECT sigla 
        FROM Ala_medica, Hospital, Estado
        WHERE
        new.Ala_medica = Ala_medica.alaNome AND
        Ala_medica.Hospital = Hospital.cep AND
        Hospital.Estado = Estado.sigla
    );
END;

------------------------------------------------------------------------------------------------------------------------------------------------

DROP TRIGGER IF EXISTS obitoPaciente;

CREATE TRIGGER obitoPaciente AFTER UPDATE 
ON Paciente
WHEN new.estado = 'Obito'
BEGIN
    -- Remove o paciente da ala médica
    UPDATE Ala_medica SET n_pacientes = n_pacientes - 1
    WHERE alaNome = (SELECT new.Ala_medica);

    -- Retorna um respirador e maca
    UPDATE Equipamentos SET resp_disp = resp_disp + 1, maca_disp = maca_disp + 1
    WHERE idEquipamentos = (SELECT Equipamentos FROM Ala_medica WHERE alaNome = new.Ala_medica);

    -- Atualiza o Banco Covid -> +1 numero de mortes
    UPDATE Dados_covid SET num_mortes = num_mortes + 1, last_att = DATETIME('now', 'localtime')
    WHERE Estado = (
        SELECT sigla 
        FROM Ala_medica, Hospital, Estado
        WHERE
        new.Ala_medica = Ala_medica.alaNome AND
        Ala_medica.Hospital = Hospital.cep AND
        Hospital.Estado = Estado.sigla
    );
END;

------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO Dependente (dep_cpf, depNome) VALUES ('12513451345', 'Jaciara');
INSERT INTO Dependente (dep_cpf, depNome) VALUES ('09878765423', 'Marco');
INSERT INTO Dependente (dep_cpf, depNome) VALUES ('53667977456', 'Bruna');
INSERT INTO Dependente (dep_cpf, depNome) VALUES ('83473782247', 'Rita');
INSERT INTO Dependente (dep_cpf, depNome) VALUES ('54665476742', 'Lelo');

INSERT INTO Telefone (num_tel, Dependente) VALUES ('61985874816', '12513451345');
INSERT INTO Telefone (num_tel, Dependente) VALUES ('61975878587', '09878765423');
INSERT INTO Telefone (num_tel, Dependente) VALUES ('61956563456', '53667977456');
INSERT INTO Telefone (num_tel, Dependente) VALUES ('61998536734', '83473782247');
INSERT INTO Telefone (num_tel, Dependente) VALUES ('61986402954', '54665476742');

INSERT INTO Orçamento (to_equip, to_manut, to_salario) VALUES ('1000000', '1000000', '1000000');
INSERT INTO Orçamento (to_equip, to_manut, to_salario) VALUES ('2000000', '1000000', '1000000');
INSERT INTO Orçamento (to_equip, to_manut, to_salario) VALUES ('3000000', '3000000', '3000000');
INSERT INTO Orçamento (to_equip, to_manut, to_salario) VALUES ('4000000', '4000000', '4000000');
INSERT INTO Orçamento (to_equip, to_manut, to_salario) VALUES ('5000000', '5000000', '5000000');

INSERT INTO Equipamentos (masc_disp, resp_disp, maca_disp) VALUES ('100', '20', '20');
INSERT INTO Equipamentos (masc_disp, resp_disp, maca_disp) VALUES ('110', '20', '20');
INSERT INTO Equipamentos (masc_disp, resp_disp, maca_disp) VALUES ('120', '20', '20');
INSERT INTO Equipamentos (masc_disp, resp_disp, maca_disp) VALUES ('130', '20', '20');
INSERT INTO Equipamentos (masc_disp, resp_disp, maca_disp) VALUES ('140', '20', '20');

INSERT INTO Estado (sigla, popul, regiao) VALUES ('DF', '2570000', 'Centro-oeste');
INSERT INTO Estado (sigla, popul, regiao) VALUES ('AL', '3322000', 'Nordeste');
INSERT INTO Estado (sigla, popul, regiao) VALUES ('RJ', '6320000', 'Sudeste');
INSERT INTO Estado (sigla, popul, regiao) VALUES ('BA', '15130000', 'Nordeste');
INSERT INTO Estado (sigla, popul, regiao) VALUES ('SP', '12180000', 'Sudeste');

INSERT INTO Hospital (cep, Estado, Orçamento, hNome, porte) VALUES ('70840-901', 'DF', '1', 'HUB', 'Médio');
INSERT INTO Hospital (cep, Estado, Orçamento, hNome, porte) VALUES ('70390-700', 'DF', '1', 'Santa Lúcia', 'Grande');
INSERT INTO Hospital (cep, Estado, Orçamento, hNome, porte) VALUES ('73015-132', 'DF', '1', 'Santa Helena', 'Grande');
INSERT INTO Hospital (cep, Estado, Orçamento, hNome, porte) VALUES ('22251-050', 'RJ', '2', 'Samaritano', 'Grande');
INSERT INTO Hospital (cep, Estado, Orçamento, hNome, porte) VALUES ('22793-310', 'RJ', '2', 'Rio Mar', 'Grande');
INSERT INTO Hospital (cep, Estado, Orçamento, hNome, porte) VALUES ('57051-190', 'AL', '3', 'Unimed', 'Grande');

INSERT INTO Ala_medica (alaNome, Hospital, Equipamentos, n_pacientes, n_leitos) VALUES ('HUB-A1', '70840-901', '1', '0', '100');
INSERT INTO Ala_medica (alaNome, Hospital, Equipamentos, n_pacientes, n_leitos) VALUES ('HUB-B1', '70840-901', '1', '0', '200');
INSERT INTO Ala_medica (alaNome, Hospital, Equipamentos, n_pacientes, n_leitos) VALUES ('S-A1', '22251-050', '2', '0', '300');
INSERT INTO Ala_medica (alaNome, Hospital, Equipamentos, n_pacientes, n_leitos) VALUES ('S-B1', '22251-050', '2', '0', '300');
INSERT INTO Ala_medica (alaNome, Hospital, Equipamentos, n_pacientes, n_leitos) VALUES ('Uni-A1', '57051-190', '3', '0', '300');
INSERT INTO Ala_medica (alaNome, Hospital, Equipamentos, n_pacientes, n_leitos) VALUES ('Uni-B1', '57051-190', '3', '0', '300');

INSERT INTO Funcionario (Ala_medica, fNome, data_admissao) VALUES ('HUB-A1', 'Mateus', '2020-08-15');
INSERT INTO Funcionario (Ala_medica, fNome, data_admissao) VALUES ('HUB-B1', 'Bruna', '2020-08-15');
INSERT INTO Funcionario (Ala_medica, fNome, data_admissao) VALUES ('S-A1', 'Func1', '2008-08-15');
INSERT INTO Funcionario (Ala_medica, fNome, data_admissao) VALUES ('S-B1', 'Func2', '2010-06-20');
INSERT INTO Funcionario (Ala_medica, fNome, data_admissao) VALUES ('Uni-A1', 'Func3', '2015-04-03');
INSERT INTO Funcionario (Ala_medica, fNome, data_admissao) VALUES ('Uni-B1', 'Func4', '2002-05-08');

INSERT INTO Email (endereco, Funcionario) VALUES ('Mateus@gmail.com', '1');
INSERT INTO Email (endereco, Funcionario) VALUES ('Bruna@gmail.com', '2');
INSERT INTO Email (endereco, Funcionario) VALUES ('Func1@gmail.com', '3');
INSERT INTO Email (endereco, Funcionario) VALUES ('Func2@gmail.com', '4');
INSERT INTO Email (endereco, Funcionario) VALUES ('Func3@gmail.com', '5');
INSERT INTO Email (endereco, Funcionario) VALUES ('Func4@gmail.com', '6');

INSERT INTO Profissao (profNome, area_atua, carga_hora, risco_expo) VALUES ('Engenheiro de Controle e Automação', 'Exatas', '40', 'Baixa');
INSERT INTO Profissao (profNome, area_atua, carga_hora, risco_expo) VALUES ('Dentista', 'Biológicas', '40', 'Medio');
INSERT INTO Profissao (profNome, area_atua, carga_hora, risco_expo) VALUES ('Ambulante', 'Comércio', '50', 'Alta');
INSERT INTO Profissao (profNome, area_atua, carga_hora, risco_expo) VALUES ('Advogado', 'Humanas', '40', 'Medio');
INSERT INTO Profissao (profNome, area_atua, carga_hora, risco_expo) VALUES ('Servidor Público', 'Indefinido', '40', 'Alta');

INSERT INTO Dados_covid (Estado, last_att, num_casos, num_mortes, num_recup) VALUES ('DF', DATETIME('now', 'localtime'), '0', '0', '0');
INSERT INTO Dados_covid (Estado, last_att, num_casos, num_mortes, num_recup) VALUES ('AL', DATETIME('now', 'localtime'), '0', '0', '0');
INSERT INTO Dados_covid (Estado, last_att, num_casos, num_mortes, num_recup) VALUES ('RJ', DATETIME('now', 'localtime'), '0', '0', '0');
INSERT INTO Dados_covid (Estado, last_att, num_casos, num_mortes, num_recup) VALUES ('BA', DATETIME('now', 'localtime'), '0', '0', '0');
INSERT INTO Dados_covid (Estado, last_att, num_casos, num_mortes, num_recup) VALUES ('SP', DATETIME('now', 'localtime'), '0', '0', '0');

INSERT INTO Paciente (pac_cpf, Profissao, Ala_medica, pacNome, estado, sexo, data_nasc, entrada, saida) VALUES ('35463564665', '1', 'Uni-A1', 'Fábio', 'Baixo', 'm', '1990-10-04', DATE('now'), null);
INSERT INTO Paciente (pac_cpf, Profissao, Ala_medica, pacNome, estado, sexo, data_nasc, entrada, saida) VALUES ('45245262566', '2', 'HUB-B1', 'Mariana', 'Baixo', 'f', '1999-12-11', DATE('now'), null);
INSERT INTO Paciente (pac_cpf, Profissao, Ala_medica, pacNome, estado, sexo, data_nasc, entrada, saida) VALUES ('87987756444', '3', 'S-B1', 'Rodrigo', 'Grave', 'm', '2002-08-06', DATE('now'), null);
INSERT INTO Paciente (pac_cpf, Profissao, Ala_medica, pacNome, estado, sexo, data_nasc, entrada, saida) VALUES ('74997878476', '4', 'S-A1', 'João', 'Médio', 'm', '1980-02-23', DATE('now'), null);
INSERT INTO Paciente (pac_cpf, Profissao, Ala_medica, pacNome, estado, sexo, data_nasc, entrada, saida) VALUES ('45856446835', '5', 'Uni-B1', 'Rosana', 'Sem risco', 'f', '1980-02-23', DATE('now'), null);

INSERT INTO DependenciaFunc (Dependente, Funcionario, parentesco) VALUES ('12513451345', 1, 'Mãe');
INSERT INTO DependenciaFunc (Dependente, Funcionario, parentesco) VALUES ('09878765423', 2, 'Pai');
INSERT INTO DependenciaFunc (Dependente, Funcionario, parentesco) VALUES ('53667977456', 3, 'Irmã');

INSERT INTO DependenciaPac (Dependente, Paciente, parentesco) VALUES ('12513451345', '35463564665', 'Sem parentesco');
INSERT INTO DependenciaPac (Dependente, Paciente, parentesco) VALUES ('83473782247', '87987756444', 'Avó');
INSERT INTO DependenciaPac (Dependente, Paciente, parentesco) VALUES ('54665476742', '45856446835', 'Tio');