# Prepare data for Switch simulation
### FR :
````
Ces dossiers contiennent l'ensemble des scripts nécessaires au prétraitement des données nécessaires à la simulation
de SWITCH. L'ensemble des scripts se trouvent dans le dossier SRC.

Afin de lancer la procédure de création complète, lancez le script CreateFiles.py.
Les données nécessaires à l'utilisation des scripts se trouvent dans IN.
Les données produites par le script se trouvent dans OUT.

Si vous supprimez les fichiers dans le dossier OUT, le script lancera les algorithmes pour les recréer à son exécution.
Il relancera aussi les algorithmes pour les fichiers dépendants si nécessaire.
````
Afin de modifier un fichier, il faut donc : Modifier le fichier source dans IN puis supprimer le fichier dans OUT.

#### Contenu de IN :

- **BATIMENT.xxx** : sont les fichiers shapefiles des bâtiments à récupérer dans la BD Topo.
- **TRONCON_DE_ROUTE.XXX** : sont les fichiers shapefile des routes à récupérer dans la BD topo.
- **EMD_depl** : est le fichier déplacement de la base de donnée EMD (enquête ménage déplacement).
- **EMD_pers** : est le fichier personne de la base de donnée EMD.


#### Contenu de OUT :

- **bati.xxx** : shapefile, contenant les bâtiments au bon format dans la zone à étudier.
- **roads.xxx** : Shapefile contenant les routes de la zone à étudier
- **depl.csv** : liste des déplacements et des heures à laquelle ils sont réalisés en fonction des individus
- **people.csv** : liste des individus de l'EMD classifiés avec shabou
- **population.csv** : population qui va peupler l'EMD (Actuellement individu de l'EMD associé à une chaîne d'activité)
- **PopulationModel** : fichier qui associe les profils Shabou à la chaîne d'activité correspondant à toutes les personnes ayant ce profil dans l'EMD.


#### Contenu de SRC :

- **CreateFiles** :  est le script principal qui appellera tous les autres dans le bon ordre.
- **CentroidandSphere** : est le script qui permet de récupérer toutes les routes et bâtiments autour de la ville à étudier.
- **Classify_Shabou** : classifie un ensemble d'individus en fonction de l'arbre de shabou (pour les jours de la semaine)
- **createActivityChain** : Créer des listes d'activité à partir du fichier depl de l'EMD en les groupant par individu
- **formatageBati** : Regroupe deux fonctions permettant de mettre les bâtiments au bon format en fonction de leur source (BD topo ou OSM) (Le script OSM doit être mis à jour en fonction des types de bati présent dans la zone à étudier).
- **FormatRoute** : permet de mettre les routes de la BD Topo au bon format.
- **PreapaDataWShabou** : est un ensemble de fonctions utilitaires pour préparer les données EMD aux traitements.

#### Dépendances :

Afin de fonctionner les scrypts python on besoin que les bibliothèque suivante soit installées:
- Pandas
- Geopandas
- OS
- Shapely
- AST

#### Guide de création de scénario :

###### Pour modifier la zone d'étude :
````
Pour modifier la zone d'étude il faut modifier 
les dossier 'BATIMENT.xxx' et 'TRONCON_DE_ROUTE.xxx'
Ainsi que la ligne "communeAEtudier = 'xxxxx' "
ou xxxxx est le numéro de la commune a étudier.
L'algorithme va récupérer toute les routes et batiment dans un rayon de 15 km autour du centre de cette commune.
Pour que cela fonctionne bien, il faut donc que la commune a étudier ce trouve dans les fichiers BATIMENT 
et TRONCON_DE_ROUTE. Actuellement les fichiers couvrent le departement du 31.
Pour changer de région, vous pouvez télécharger les données dans la bd topographique.
Le rayon d'étude peux être modifier dans le code en modifiant la ligne 44 : diametre = 15000
````
pour télécharger la bd topographique d'une nouvelle region :
<https://geoservices.ign.fr/bdtopo>
````
Pour modifier les infrastructures routier sur une zone d'étude deja existant, vous pouvez les modifiers directement
dans les fichiers TRONCON_DE_ROUTE et BATIMENT.
en respectant le format de données de la bd topo pour les routes.
Pour les batiments, il est possible d'utiliser les données OSM ou Topographique. L'algorithme de base utilisé est celui pour la bd TOPO.
Pour cela vous pouvez utiliser un logiciel comme qgis ou arcgis.
````
###### Pour modifier la population : 
````
Pour modifier la population, il faut modifier le fichier lu a la ligne 22 "src_pop = '../IN/population.csv'"
actuellement la population utilisé et la même que l'EMD de Toulouse. Pour modifier la population vous pouvez modifier directement
le fichier ou en télécharger un nouveau. Il faut que le fichier corresponde au format de l'EMD Toulouse.
Toute les colones ne sont pas utiliser les utiles sont :
P2(genre), P4(age), P8(niveau d'étude), P9(activité principale) et PCSD(Catégorie socioprofessionnelle)
````

