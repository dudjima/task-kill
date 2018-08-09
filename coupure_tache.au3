#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <File.au3>
#include <WinAPISys.au3>

#include "..\constantes.au3"

;On liste toute les taches galss
$duree = 15000
$architecture = @CPUArch
$fichier_log = $dossier_logs & "\gestion_galss_logs.log"
$version 		= _WinAPI_GetVersion
$fichier_config = $dossier_config & "\surveillance_galss.ini"
If $version 	= "6.1" Then $architecture = "x32" ; on force le 32 bits pour windows 7
; on genere un fichier INI

if FileExists($fichier_config) = 0 Then
	IniWrite($fichier_config, "config", "attente", "15000")
	IniWrite($fichier_config, "config", "architecture", @CPUArch)
	IniWrite($fichier_config, "config", "log", $dossier_logs & "\gestion_galss_logs.log")
EndIf

$duree 			= IniRead($fichier_config, "config", "duree", "15000")
$architecture 	= IniRead($fichier_config, "config", "architecture", @CPUArch)
$fichier_log 	= IniRead($fichier_config, "config", "log", $dossier_logs & "\gestion_galss_logs.log")

If FileExists($fichier_log) = 0 Then
	_FileWriteLog($fichier_log, "Initialisation du suivi de galss")
	_FileWriteLog($fichier_log, "Version  de Windows : " & $version)
	_FileWriteLog($fichier_log, "Architecture  : " & @CPUArch)
EndIf

	_FileWriteLog($fichier_log, "debut suivi")
While 1
	$liste64 = ProcessList("galsvw64.exe")
	if @error Then _FileWriteLog($fichier_log, "ERREUR #0 : process liste galss 64")

	$liste32 = ProcessList("galsvw32.exe")
	if @error Then _FileWriteLog($fichier_log, "ERREUR #1 : process liste galss 32")

	$nombre =  $liste32[0][0] + $liste64[0][0]
	_FileWriteLog($fichier_log,"nombre de processus : " & $nombre)
	sleep(15000)

	If $nombre <> 1 Then ; si on a plus de un process lancé
		_FileWriteLog($fichier_log, "Succes #2 : incoherance processus")
		If $architecture = "x64" Then
			If $liste32[0][0] > 0 Then
				ProcessClose("galsvw32.exe")
				if @error Then
					_FileWriteLog($fichier_log, "ERREUR #3_64 : Coupure du processus galsvw32.exe, sur machine 64bits")
				Else
					_FileWriteLog($fichier_log, "Succes #3_64 : Coupure du processus galsvw32.exe, sur machine 64bits")
				EndIf
			EndIf

			If $liste64[0][0] > 1 Then
				For $i = 1 To $liste64[0][0] - 1
					ProcessClose($liste64[$i][0])
					If @error Then
						_FileWriteLog($fichier_log, "ERREUR #4_64 : Coupure du processus galsvw64.exe trop")
					Else
						_FileWriteLog($fichier_log, "Succes #4_64 : Coupure du processus galsvw64.exe trop")
					EndIf
				Next
			EndIf

			If $liste64[0][0] = 0 Then
				Run("galsvw64.exe")
				if @error Then
					_FileWriteLog($fichier_log,"#ERREUR 5_64 : lancement galss 64")
				Else
					_FileWriteLog($fichier_log,"#Succes 5_64 : lancement galss 64")
				EndIf
			EndIf

		Else ; on est en 32 bits donc
			If $liste32[0][0] > 1 Then
				For $i = 1 To $liste64[0][0] - 1
					ProcessClose($liste64[$i][0])
					If @error Then
						_FileWriteLog($fichier_log, "ERREUR #4_32 : Coupure du processus galsvw32.exe trop")
					Else
						_FileWriteLog($fichier_log, "Succes #4_32 : Coupure du processus galsvw32.exe trop")
					EndIf
				Next
			EndIf

			If $liste32[0][0] = 0 Then
				run("galsvw32.exe")
				if @error Then
					_FileWriteLog($fichier_log,"#ERREUR 5_32 : lancement galss 32")
				Else
					_FileWriteLog($fichier_log,"#Succes 5_32 : lancement galss 32")
				EndIf
			EndIf
		EndIf
	EndIf
WEnd