/**************ENGRENAGE DROIT**************
**************DÉFINITIONS**************

le cercle de pied, qui est le cercle passant par la base des dents ;
le cercle de tête, qui passe par le sommet des dents ;
le cercle de base, qui est celui qui sert à générer le profil des dents (les dents sont des développantes de ce cercle) ;

le cercle primitif : les cercles primitifs des roues dentées d'un engrenage ont la même vitesse tangentielle ; ils passent à peu près au milieu des dents.

**************NOTATIONS**************

diamètre primitif => d
diamètre de pied => df
diamètre de tête => da
diamètre de base => db

angle de pression => alpha

module => m

pas (distance entre 2 dents sur le cercle primitif) => p

saillie => ha
creux => hf

hauteur de dent => h
nombre de dents => z

largeur de la dent sur le cercle primitif => l
angle d'une dent sur le cercle primitif => la

**************RELATIONS**************

d = m*z
p = m*pi
ha = m

si m<=1.25 hf = 1.40*m
sinon hf = 1.25*m

si m<=1.25 h = 2.40*m
sinon h = 2.25*m

h = ha + hf <=> ha = h - hf <=> ha = 2.25m - 1.25m = m
ha = m

da = d + 2*ha = d + 2*m
df = d - 2*hf = d -2.5*m
db = d*cos(alpha)

l = pi*m/2 = pi/2 * d/z = (pi * d)/(2 * z) = pi*r/z = p/2

deport de denture
calcul de la largeur d'une dent avec déport : http://www.sidermeca.com/ficheconseil.php?fiche=1

/*************ATTENTION*************
la différence entre le nombre de dents de 2 roues
est limité dans certains cas

si Za=13, Zbmax=16
si Za=14, Zbmax=26
si Za=15, Zbmax=45
si Za=16, Zbmax=101
si Za=17, Zbmax=sans limite

de préférence choisir des nombres premiers entres eux
*/

$fn = 200;

pi = 3.1415926535;

//CONVERSION
function rad(angle = 0) = pi * angle / 180;
function degre(angle = 0) = angle * 180 / pi;

//DEVELOPPANTE DE CERCLE
function developpante_x(r = 1, a = 0) = r*(cos(a)+rad(a)*sin(a));
function developpante_y(r = 1, a = 0) = r*(sin(a)-rad(a)*cos(a));

//INTERSECTION
/*On cherche à calculer le point d'intersection
d'une développante de cercle et d'un cercle.
Pour se faire il faut chercher la valeur du paramètre a dans les équations :
x(a) = r*(cos(a) + a*sin(a))
y(a) = r*(sin(a) - a*cos(a))

En utilisant pythagore on conclue que le paramètre doit satisfaire :
tel que x(a)² + y(a)² = R²
avec R le rayon du cercle que coupe la développante.

[r*(cos(a) + a*sin(a))]² + [r*(sin(a) - a*cos(a))]² = R²
r² * (cos(a) + a*sin(a))² + r² * (sin(a) - a*cos(a))² = R²

On peut factoriser par r²
r² * [ (cos(a) + a*sin(a))² + (sin(a) - a*cos(a))² ] = R²
(cos(a) + a*sin(a))² + (sin(a) - a*cos(a))² = R²/r²

On utilise les identitées remarquables :
cos(a)² + 2a*cos(a)*sin(a) + a²*sin(a)² + sin(a)² - 2a*cos(a)*sin(a) + a²*cos(a)² = R²/r²
cos(a)² + a²*sin(a)² + sin(a)² + a²*cos(a)² = R²/r²
cos(a)² + sin(a)² + a²*sin(a)² + a²*cos(a)² = R²/r²
cos(a)² + sin(a)² + a²*( sin(a)² + cos(a)² ) = R²/r²

Sachant que cos² + sin² = 1 on obtient :
1 + a² = R²/r²
a² = R²/r² - 1
a = sqrt(R²/r² - 1)
*/

function intersect_rad(r=1, R=2) = sqrt( (R*R)/(r*r) - 1);
function intersect(r=1, R=2) = degre(intersect_rad(r, R));

function creux(m = 1) = m <= 1.25 ? 1.4*m : 1.25*m;

module dent_cremaillere_2D(m = 1, alpha = 20)
{
    //hauteurs
    hf = creux(m);
    ha = m;
    h = hf + ha;
    
    //pas
    p = m*pi;
    
    //vecteurs
    /*calcul des points de la dents
    on part de l'origine [0, 0], pour monter jusqu'à y = h suivant un angle alpha. On notera l la longueur de la dent.
    On peut donc écrire :
    l*sin(alpha) = decalage_x
    l*cos(alpha) = h
    en faisant la première ligne divisé par la seconde on obtient :
    l*sin(alpha) / l*cos(alpha) = decalage_x / h
    Or l se simplifie et sin/cos = tan, on obtient donc :
    tan(alpha) = decalage_x / h
    et donc decalage_x = h*tan(alpha)
    */
    pan_montant = [ [0, 0], [h*tan(alpha), h] ];
    descente = [ [-h*tan(alpha), h], [0, 0] ];
    
    /*Pour les même raison qu'avant, mais pour une hauteur hf on obtient le décalage en x
    au niveau de la droite primitive. Endroit où la dent doit avoir une largeur d'un demi-pas.
    Il faut prendre en compte le décalage en x à droite et à gauche d'où le facteur 2.
    */
    largeur_base = [2*hf*tan(alpha) + p/2, 0];
    pan_descendant = descente + [ largeur_base, largeur_base ];
    
    dent = concat(pan_montant, pan_descendant);
    
    polygon(dent);
}

module cremaillere_2D(z = 10, m = 1, alpha = 20, largeur = 10)
{
    //hauteurs
	hf = creux(m);
    
    //pas
    p = m*pi;
    
    union()
    {
        translate([0, -largeur, 0])
        {
            square([p* (z - 1) + p/2 + 2*hf*tan(alpha), largeur]);
        }
     
        for(i=[0:z-1])
        {
            translate([p*i, 0, 0])
            {
                dent_cremaillere_2D(m, alpha);
            }
        }
    }
}

module cremaillere_3D(z = 10, m = 1, alpha = 20, largeur = 10, epaisseur = 3)
{
    linear_extrude(epaisseur)
    {
        cremaillere_2D(z, m, alpha, largeur);
    }
}

module roue_dentee_2D(z = 10, m = 1, alpha = 20, deport = 0)
{    
	//hauteurs
	hf = creux(m) - deport;
    ha = m + deport;
    
    //calcul des diamètres
    d = m * z;
    db = d * cos(alpha);
    df = d - 2*hf;
    da = d + 2*ha;
    
    //calcul de l'angle entre 2 dents
    angle_dent = 360 / z;
    
    //pas
    p = m*pi;
    
    //largeur de la dent sur le cercle primitif
    l = pi*d/(2*z) + 2*deport*sin(alpha);
    
    //angle de la dent sur le cercle primitif
    //la = degre( l/(d/2) ); équivalent à :
    la = 2*degre(l/d);
    
    //paramètre d'intersection de la developpante avec le cercle primitif
    //Id = intersect(db/2, d/2); équivalent à :
    Id = intersect(db, d);
    
    //angle entre la base de la dent et l'intersection avec le cercle primitif
    angle1 = atan2( developpante_y(db/2,Id), developpante_x(db/2,Id) );
    //angle de la dent à sa base
    angle_base = la + 2*angle1;
    
    //paramètre d'intersection de la developpante avec le cercle de tête
    //Ida = intersect(db/2, da/2); équivalent à :
    Ida = intersect(db, da);

    //GENERATION DE LA DENT
    
    /*Lors d'un déport de denture trop prononcé les développantes de cercles se croisent donnant lieu à 
    un "petit triangle" sur la pointe de la dent. Pour éviter ça il faut déterminer l'angle à ne pas dépasser.
    
    La développante de cercle ne devrait jamais croiser l'axe de symétrie de la dent.
    On en déduit donc que la droite passant par l'origine O et faisant un angle de "angle_base/2" avec l'axe x est la limite.
    On note I le point d'intersection de cette droite avec la développante de cercle et T un point du cercle de base (angle positif) tel que
    IT soit une tangente.
    
    CARACTÉRISTIQUES CONNUES DE LA FIGURE :
    0) L'angle xOI est angle_base/2
    1) L'angle IOT sera appelé alpha
    2) L'angle xOT est le paramètre de la développante de cercle, on le notera a.
    3) De part sa construction le triangle OIT est rectangle en T.
    4) OT est un rayon du cercle de base, on notera sa longueur r
    5) La longueur IT est proportionnelle à r et à l'angle xOT. Avec a en radiant on obtient : IT = ra
    6) D'après le théorème de pythagore OI² = IT² + TO²
    7) Dans un triangle rectangle : hypothénuse * cos(alpha) = coté adjacent
    
    DÉDUCTIONS :
    OI² = IT² + TO²
    OI² = r²a² + r² = r² * (1 + a²)
    OI = sqrt(r² * (1 + a²) )
    OI = r * sqrt(1 + a²)
    Or OI est l'hypoténuse on peut dont écrire :
    OI * cos(alpha) = r
    r * sqrt(1 + a²) * cos(alpha) = r
    sqrt(1 + a²) * cos(alpha) = 1
    cos(alpha) = 1 / sqrt(1 + a²)
    alpha = acos( 1 / sqrt(1 + a²) )
    
    Dans le cas où la developpante de cercle est tracé jusqu'au point I alors on a :
    a = angle_base/2 + alpha
    Le paramètre a ne doit donc pas dépasser cette valeur.
    
    */
    
    A = [ for(i=[0:Ida])
           if( i < angle_base/2 + acos( sqrt( 1/(1 + rad(i) * rad(i)))) )
           [developpante_x(db/2,i), developpante_y(db/2,i)] ];
    
    Matrice_de_rotation = [ [cos(angle_base), -sin(angle_base)], [sin(angle_base), cos(angle_base)] ];
    
    //Pour continuer le polygone il faut parcourir les valeurs dans l'autre sens
    B = [ for(i=[-Ida:0])
          if( i > -angle_base/2 - acos( sqrt( 1/(1 + rad(i) * rad(i)))) ) 
          Matrice_de_rotation*[developpante_x(db/2,i), developpante_y(db/2,i)] ];
                        
    C = concat(A, B);

    //pied de la dent
    circle(d=df);
    
    for(j = [0:1:z-1])
    {
        rotate([0, 0, j*angle_dent])
        {
            polygon(C);
        }
    }
}

module roue_dentee_3D(z = 20, m = 5, alpha = 20, epaisseur = 2, deport = 0)
{
    linear_extrude(epaisseur)
    {
        roue_dentee_2D(z,m,alpha, deport);
    }
}

/**************ENGRENAGE HELICOÏDAL**************/
/*Dans un engrenage hélicoïdal la denture est "penchée", on distingue donc 2 profiles

-Le profil réel, qui correspond à une coupe droite de la dent, une coupe par un plan perpendiculaire aux arêtes, module réel noté mr (noté parfois mn)

-Le profil apparent, qui correspond à une coupe selon un plan perpendiculaire à l'axe du cylindre module apparent : ma (noté parfois mt)

le module réel "mr" et le module apparent "ma" sont lié par :
mr = ma*cos(beta)

beta étant l'angle que fait la dent avec l'axe de rotation

**************RELATIONS**************

relation pas - module :
p = pi*m

relation pas réel - pas apparent :
pa = pr/cos(beta)

relation module réel - module apparent :
ma = mr/cos(beta)

relation angle de pression réel - angle de pression apparent :
tan(alpha_r) = tan(alpha_a)*cos(beta)
alpha_a = arctan(tan(alpha_r)/cos(beta))

diamètre primitif :
d = Z*mr / cos(beta)
d = Z*ma

diamètre de tête
D = d + 2*mr

nombre de dent :
Z = d*cos(beta)/mr

*/

module roue_dentee_helicoidale(z = 40, m = 1, alpha = 20, beta = 60, epaisseur = 10, deport = 0)
{
	/*le paramètre twist est le nombre de degrés effectué pendant l'extrusion

    pour un schéma détaillé voir :
    http://www.zpag.net/Machines_Simples/engrenage_droit_dent_helicoidale.htm

	ATTENTION !!
	Pour engrainer les différentes roues dentées doivent avoir le même MODULE RÉEL !!
	Or roue_dentee_2D correspond à la coupe transversale de la roue dentée, dans ce plan là il s'agit du module apparent.
	La conversion se fait grâce à la relation : mr = ma*cos(beta);
	*/
    
    //CALCUL DES PARAMETRES APPARENTS
	ma = m/cos(beta);
    alpha_a = atan2(tan(alpha),cos(beta));
    
    //CALCUL DU TWIST
    /*Dans la suite tous les paramètres seront sur le cercle primitif. Pour calculer l'angle de rotation pendant l'extrusion il faut résoudre 2 triangles. Le premier est celui qui part du bord d'une dent à la base de la roue dentée (point A), monte à la verticale sur surface supérieure (point B) et termine sur le point équivalent au point A mais sur la surface supérieure (point C). Le deuxième triangle est OBC avec O le centre de la roue dentée.
    
    CARACTÉRISTIQUES CONNUES DE LA FIGURE :
    0) l'angle BAC = beta
    1) la distance AB est l'épaisseur de la roue dentée
    2) les distances OB et OC sont le rayon du cercle primitif

    DÉDUCTIONS :
    Sachant que AB*tan(beta) = BC et que BC est une corde du cercle alors si on nomme l'angle BOC theta on peut écrire :
    2*OC*sin(theta/2) = BC. En égalisant les deux relations on obtient :
    AB*tan(beta) = 2*OC*sin(theta/2)
    AB*tan(beta)/(2*OC) = sin(theta/2)
    asin(AB*tan(beta)/(2*OC)) = theta/2
    2*asin(AB*tan(beta)/(2*OC)) = theta
    
    Theta est notre angle de twist. Les notations du script sont :
    AB = epaisseur
    beta = beta
    2*OC = d = z*ma
    theta = angle
    
    On obtient donc : 
    angle = 2*asin(epaisseur * tan(beta) / (z*ma));
    Cependant lorsque l'épaisseur devient trop importante alors on sort du domaine de définition de la fonction asin et le résultat devient incohérent. Pour palier à ce problème on va considérer que notre roue dentée est une succession de couches, comme lors d'une impression 3D. De ce fait on peut calculer l'angle entre 2 couches et par une règle de 3 on obtient le twist total.
    */
    h = 0.01;   //couches fines
    gamma = 2*asin(h * tan(beta) / (z*ma));
	angle = epaisseur*gamma/h;
	
	linear_extrude(height = epaisseur, twist = angle)
	{
        roue_dentee_2D(z, ma, alpha_a, deport);
    }
}

module roue_dentee_chevron(z = 40, m = 1, alpha = 20, beta = 60, epaisseur = 10, deport = 0)
{
    //CALCUL DES PARAMETRES APPARENTS
	ma = m/cos(beta);
    
    //CALCUL DU TWIST
    h = 0.1;   //couches fines
    gamma = 2*asin(h * tan(beta) / (z*ma));
	angle = epaisseur*gamma/h;
	
    roue_dentee_helicoidale(z, m, alpha, beta, epaisseur/2, deport);
    
    translate([0, 0, epaisseur/2])
    {
        rotate([0, 0, -angle/2])
        {
            roue_dentee_helicoidale(z, m, alpha, -beta, epaisseur/2, deport);
        }
    }
}