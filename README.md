SWITCH-23
==========

Installation de switch
-----------------------

1. Installer Gama git (version 1.9.0 ou +) ( https://github.com/gama-platform/gama/wiki/InstallingGitVersion#installing-the-git-version )

2. Importer la dernière version des plugins switch et switch feature, dans les plugins expérimental (actuellement la version d'Olivier)

3. Ajouter irit.gama.feature.switchproject dans content gama.product

4. Importer le code de switch (sur ce git).

5.  Lancer gama avec eclipse.

6.  Définir le répertoire importer comme workspace git

-----------------------

Utilisation de switch
-----------------------

### lancer une simulation
1. Ouvrir models/World.gaml pour acceder au main du projet Switch.

2. Lancer Text only pour lancer la simulation la plus rapide, n'affichant que quelques informations pour suivre l'etat de la simulatuion dans la console Gama.

3.  A la fin de la simulation, vous trouverez un fichier "lateness.csv" dans le dossier logs_file.
        Ce fichier enregistre a chaque sortie de chaque route les informations concerant le deplacement de l'individu en train de sortir de la route
        nom des colonnes : ID,TopoId,distance,entry date,duration,mean speed,lateness
        ID : Identifiant du vehicule
        TopoID : Identifiant de la route dans la bd Topo
        distance : longueure de la route
        entry date : date d'entree de l'individu sur la route
        duration : temps passe sur la route
        mean speed : vitesse moyenne sur la portion de route
        lateness : retard pris sur la route par rapport a la duree de trajet estime

4. Vous trouverez dans le dossier DataScript/SRC/plotRoad.ipynb different scripts a executer afin de realiser une carte permettant de montrer les congestions et la frequentation des routes presentent dans le dossier lateness.csv (actuellement le '[' et le ']' au debut et a la fin du fichier doivent encore etre enlever a la main actuellement)
    D'autres scripts peuvent etre imaginer pour avoir une autre representation des donnees
                grouper les donnees sur ID pour avoir les donnees par individu plutot que par route par exemple

-----------------

### Modifier les scenarios de la simulation :
#### changer les fichiers utilisé par la simulation 
modifier ces lignes Dans World.gaml : 
* pour les routes : modifier la ligne 36 qui est le chemin d'acces pour les routes dans la simulation. actuellement il existe roadImportance1 a roadImportanc4

* pour la population :  
ligne 46 est le chemin d'acces pour le fichier patron de la population.
        2. ligne 47, nbBoucle et le nombre de fois ou le patron sera uiliser pour instancier la population.
(si le patron de population contient 1000 personnes et nbBoucle = 5, la simulation aura 5000 individu dans la sim)

#### Scénario existant 
Différent scénario ont déja été implémenté et simulé. Vous trouverez les différents fichiers sources dans includes/roads/basicScenario/, includes/roads/speedLimitScenario/ et includes/population/ ainsi que les résultats dans DataScript/SimResult
Les différents scénario déja testé sont : 

--------------------------
passage de toulouse en ZFE 3, soit 30% de la population ne peut plus se déplacer en voiture.
nom du fichier source :
>       Pop2over3.csv
resultat :
>       lateness2over3.csv

---------------------------
Télétravail pour les professions intellectuelles supérieur et étudiants :
nom du fichier source :
>       Pop3&7TT.csv
resultat :
>       latenessTTfor3&7.csv

----------------------------
augmentation et diminution de la vitesse en ville de 20 km/h :
nom des fichiers sources :
>       speedLimitScenario/road3decrease3with20/roads.shp
>       speedLimitScenario/road3increase3with20/roads.shp
resultats : 
>       latenessDecrease3with20.csv et latenessIncrease3with20

---------------------
augmentation et diminution de la vitesse du périph et autoroute de 30 km/h :

nom des fichiers sources : 
>       speedLimitScenario/road3decrease1with30/roads.shp 
>       speedLimitScenario/road3increase1with30/roads.shp    
        
resultats :
>       latenessDecrease1with30.csv
>       latenessIncrease1with30.csv

-------------------------

Pour modifier les fichiers en source referez vous au readme present dans le dossier DataScript afin d'avoir plus d'information sur le format des donnees dans les fichers sources