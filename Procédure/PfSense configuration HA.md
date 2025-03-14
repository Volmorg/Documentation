## Mettre en place la haute disponibilité sur PfSense

pour mettre en place la HA (hight availability) sur PfSense, il faut commencer par crée une **adresse IP virtuelle** qui sera utilisé à tour de role par les serveurs PfSense pour assuré la continuité des services; ceci est réalisé grâce au protocole CARP. 
Il y a deux autres protocoles que nous utiliserons: pfSync et XMC-RPC.

- pfSync permet la synchronisation entre les serveurs PfSense et la transmissions des connexions en cours.
- XMC-RPC quand à lui permet la transmission de données entre les serveurs. Pour garantir son fonctionnement, il doit être mis en place sur même interface que pfSync

### Création de l'adresse IP virtuelle (VIP)

Rendez-vous dans l'onglet firewall puis dans Virtual IPs et ajouter une nouvelle IP virtuelle

#### Type
>Nous utiliserons ici le type CARP

#### Interface
> sélectionné l'interface sur laquelle vous voulez déployé votre VIP

#### address 
> entré l'adresse IP que vous voulez utilisé comme virtuelle
> **ATTENTION** utilisé une adresse VALIDE sur le réseau de votre interface ET qui n'est pas utilisé par une carte virtuelle
 
#### Virtual IP Password
> Mot de passe permettant de sécurisé les échanges entres les hôtes qui partagerons cette adresse

#### VHID Group (Virtual host identifier)
>permet aux hôtes de s'identifier, un hôte peux faire partie de plusieurs groupe. Nous laisseront la valeur par défaut

#### Advertising Frequency
>la valeur du champ "skew" permettra aux hôtes de savoir qui est le serveur primaire et qui est le secondaire, plus la valeur est élevé, plus l'hôte qui l'a est secondaire. Nous laisseront la valeur par défaut

Une fois votre adresse réaliser sur votre interface WAN, réaliser la même opération sur l'interface LAN.
Enfin réaliser la même configuration sur le PfSense de secours en pensant bien à changer la valeur du champ **skew** à 1. Faites attention au VHID Group, pour chaque VIP il doit être identique sur les deux firewall

### Vérification
> Pour vérifier que vos VIP sont bien configuré et prise en compte, rendez-vous dans l'onglet status > CARP (failover)

Si tout c'est bien passé, votre VIP sont bien configuré avec deux MASTER sur votre PfSense principale, et deux BACKUP sur votre PfSense secondaire.

## Forçage des VIP
Vos VIP sont configuré mais pas utilisé, il faut donc indiquer à PfSense d'utilisé ces VIP.

#### Utiliser les VIP
> Rendez-vous dans l'onglet firewall > NAT
> changer le mode utilisé par le NAT pour: **Hybrid Outbound NAT rule generation.
(Automatic Outbound NAT + rules below)
> cliquer sur "save"

a présent nous allons crée une nouvelle règle pour utilisé les VIP:

#### Disable
>la case Disable désactivera la règle quand elle sera crée, laissez la décocher

#### Do not NAT
>Cocher cette case permet de désactivé le NAT pour cette règle, elle sera très rarement utilisé. Nous la laisseront décocher

#### Interface
>l'interface sur laquelle nous allons appliqué notre règle de NAT; ici l'interface WAN

#### Protocol
> Les protocoles concerné par cette règle de NAT, ici "any"

#### Source
> Le réseau source, dans notre cas, le réseau local

#### Destination
> le réseau de destination, dans notre cas nous mettrons "any"

#### Address
>l'adresse IP à utilisé pour cette règle, c'est ici que nous renseignons la VIP crée auparavant

#### Port
> spécifie un port pour cette règle de NAT, nous le laisseront vide

#### No XMLRPC Sync
>Cocher cette case pour ne pas copier les paramètre sur le serveur secondaire. Nous laisseront cette case décocher

#### Description
> un champ informatif pour décrire ce que fait cette règle

## Configuration de la Haute Disponibilité
Rendez-vous dans System > High Avail. Sync

### State Synchronization settings (PfSync)

#### Synchronize states
>cocher cette case pour activé PfSync

#### Synchronize interface
>Si vous avez mis en place une interface supplémentaire pour synchroniser les PfSense, choisissez la; ici nous sélectionneront LAN

#### Filter Host ID
>Identifiant utilisé par le protocole PfSync; laisser le champ laisserai PfSense choisir. Laissez vide

#### PfSync synchronize Peer IP
>saisir l'adresse du serveur PfSense de secours. attention à respecter l'IP en rapport avec l'interface de synchronisation que vous avez choisis plutôt. Si aucune adresse n'est mise, PfSense diffusera en multicast (donc faille de sécurité)
>**ATTENTION** Il faudra rentré l'adresse IP du PfSense **principale** à cette endroit sur **le PfSense secondaire**

### Configuration Synchronization settings (XMLRPC Sync)

#### Synchronize Config to IP
>indiquer l'adresse IP à laquelle le PfSense envera les données. (ici l'IP du PfSense de secours)
#### Remote System Username
>indiquer le nom d'utilisateur de l'administrateur du PfSense de secours
#### Remote System Password
>indiquer le mot de passe correspondant (si vous ne l'avez pas changer, FAITES LE)
#### Synchronize admin
> synchronise les comptes administrateur entre les deux PfSense.
#### Select options to sync
> permet de sélectrionner les données des services que vous souhaitez synchronise; ici nous sélectionnons tout

Sauvegardé et c'est configuré ! :)

## Autorisation sur le pare-feu

rezndez-vous dans l'onglet firewall > rules
Nous avons deux règles à ajouter sur l'interface sur laquelle nos PfSense vont communiqué:
- Le flux pour la synchronisation XMLRPC (port 443)
- le flux pour la synchronisation PfSync

*Vous aurez besoin de crée deux règles pour chaque adresse IP; si vous souhaitez suivre les bonne pratiques, crée un alias (onglet firewall > allias ) contenant les deux adresses IP des interfaces de synchronisation*

---
### Création d'une règle pour autorisé XMLRPC

#### Action
>Pass

#### Interface
>indiquer l'interface sur laquelle nous allons mettre en place la règles. Ici LAN

#### Address Family
> indiquer si cette règles affecte l'IPv4 ou IPv6. Pour nous ce sera IPv4

#### Protocol
>indiquer le protocole concerné par cette règle. Dans notre cas ce sera TCP

#### Source
> indiquer l'adresse Source. Renseigner l'allias crée ou une des deux adresse IP des interface de synchronisation de PfSense secondaire (vous devrez crée une seconde règle identique avec l'autre adresse IP)

#### Destination
>indiquer l'adresse de destination, dans notre cas "My firewall(self)"

#### Destination Port Range
>choisir le protocole HTTPS (443)

#### Description
>indiquer à quoi servira cette règle. (champ informatif non obligatoire)

---
### configuration de la règle pour autorisé PFSYNC

#### Action
>Pass

#### Interface
>indiquer l'interface sur laquelle nous allons mettre en place la règles. Ici LAN

#### Address Family
> indiquer si cette règles affecte l'IPv4 ou IPv6. Pour nous ce sera IPv4

#### Protocol
>indiquer le protocole concerné par cette règle. Dans notre cas ce sera PFSYNC

#### Source
> indiquer l'adresse Source. Renseigner l'allias crée ou une des deux adresse IP des interface de synchronisation de PfSense secondaire (vous devrez crée une seconde règle identique avec l'autre adresse IP)

#### Destination
>indiquer l'adresse de destination, dans notre cas "My firewall(self)"

#### Description
>indiquer à quoi servira cette règle. (champ informatif non obligatoire)

