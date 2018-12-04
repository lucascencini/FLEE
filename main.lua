-- Debuger console
io.stdout:setvbuf('no')

-- Empèche Love de filtrer les contours des images quand elles sont redimentionnées
-- Indispensable pour du pixel art
love.graphics.setDefaultFilter("nearest")

-- Cette ligne permet de déboguer pas à pas dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end

-------------------------- VARIABLE GLOBAL -----------------------------------------------

local SCREEN_WEIGHT = love.graphics.getWidth()/2
local SCREEN_HEIGHT = love.graphics.getHeight()/2

local hero = {}

local camera = {}
camera.x = 0;

local musicManager = {}

local compteur = 0 -- Incrémental / permet de savoir quand changer de niveau

----------------------------- ECRAN COURANT ----------------------------------------------

ecran_courant = "Menu"

--------------------------- MUSIC POUR ZONES ---------------------------------------------

local musicCool = love.audio.newSource("sons/cool.mp3", "stream")
local musicTechno = love.audio.newSource("sons/cool.mp3", "stream")

local sndJump = love.audio.newSource("sons/sfx_movement_jump13.wav","static")
local sndLanding = love.audio.newSource("sons/sfx_movement_jump13_landing.wav","static")

-------------------------- IMAGES ECRANS -------------------------------------------------

local imgMenu = love.graphics.newImage("images/Ecrans/Start.png")
local imgGameOver = love.graphics.newImage("images/Ecrans/Game_over.png")
local imgEnd = love.graphics.newImage("images/Ecrans/End.png")

--------------------------- FOND ZONES ---------------------------------------------------

local BGImageSize = love.graphics.newImage("images/Ecrans/Size.png")

-- Premier niveau ville jour
local imgBGVillejour_fond = love.graphics.newImage("images/Ville_aube/ville_jour_couche_fond.png")
local imgBGVillejour_l1 = love.graphics.newImage("images/Ville_aube/ville_jour_couche_l1.png")
local imgBGVillejour_l2 = love.graphics.newImage("images/Ville_aube/ville_jour_couche_l2.png")
local imgBGVillejour_l3 = love.graphics.newImage("images/Ville_aube/ville_jour_couche_l3.png")
local imgBGVillejour_l4 = love.graphics.newImage("images/Ville_aube/ville_jour_couche_l4.png")
local imgBGVillejour_l5 = love.graphics.newImage("images/Ville_aube/ville_jour_couche_l5.png")
local imgBGVillejour_l6 = love.graphics.newImage("images/Ville_aube/ville_jour_couche_l6.png")
local imgBGVillejour_l8 = love.graphics.newImage("images/Ville_aube/ville_jour_couche_l8.png")
local imgBGVillejour_train = love.graphics.newImage("images/Ville_aube/ville_jour_couche_l7_train.png")

-- Deuxième niveau ville ocean
local imgBGVilleOcean_0 = love.graphics.newImage("images/Ville_ocean/ville_ocean_fond.png")
local imgBGVilleOcean_1 = love.graphics.newImage("images/Ville_ocean/ville_ocean_l1.png")
local imgBGVilleOcean_2 = love.graphics.newImage("images/Ville_ocean/ville_ocean_l2.png")
local imgBGVilleOcean_3 = love.graphics.newImage("images/Ville_ocean/ville_ocean_l3.png")
local imgBGVilleOcean_4 = love.graphics.newImage("images/Ville_ocean/ville_ocean_l4.png")
local imgBGVilleOcean_5 = love.graphics.newImage("images/Ville_ocean/ville_ocean_l5.png")
local imgBGVilleOcean_6 = love.graphics.newImage("images/Ville_ocean/ville_ocean_l6.png")
local imgBGVilleOcean_7 = love.graphics.newImage("images/Ville_ocean/ville_ocean_l7.png")
local imgBGVilleOcean_8 = love.graphics.newImage("images/Ville_ocean/ville_ocean_l8.png")
local imgBGVilleOcean_9 = love.graphics.newImage("images/Ville_ocean/ville_ocean_l9.png")

-- Position horizontale du fond (pour scrolling)
local bgX = 1
local bgX_1 = 1
local bgX_2 = 1
local bgX_3 = 1
local bgX_4 = 1
local bgX_5 = 1
local bgX_6 = 1
local bgX_7 = 1
local bgX_8 = 1
local bgX_9 = 1
local bgX_10 = 1

--------------------------- CreateHero ---------------------------------------------------
function CreateHero()
    local Hero = {}
    -- Sa position
    Hero.x = 0
    Hero.y = 0
    -- Sa vélocité verticale
    Hero.velocityVertical = 0
    -- Par défaut il n'est pas en train de sauter
    Hero.jump = false
    -- Liste des images de l'animation
    Hero.listeImagesAnim = {}

    -- Charge les images dans une liste
    local n
    for n=1,8 do
      local myImg = love.graphics.newImage("images/Personnage/hero-day-"..n..".png")
      table.insert(Hero.listeImagesAnim,myImg)
    end

    -- On commence par la 1ère image
    Hero.currentImage = 1

    -- On note sa taille
    Hero.width = Hero.listeImagesAnim[1]:getWidth()
    Hero.height = Hero.listeImagesAnim[1]:getHeight()

    return Hero
end
--------------------------- MusicManager ---------------------------------------------------

-- Fonction créant et renvoyant un MusicManager
function CreateMusicManager()
  local myMM = {}
  myMM.lstMusics = {} -- Liste des musiques du mixer
  myMM.currentMusic = 0 -- ID de la musique en cours

  -- Méthode pour ajouter une musique à la liste
  function myMM.addMusic(pMusic)
    local newMusic = {}
    newMusic.source = pMusic
    -- S'assure de faire boucler la musique
    newMusic.source:setLooping(true)
    -- Coupe le volume par défaut
    newMusic.source:setVolume(0)
    table.insert(myMM.lstMusics, newMusic)
  end


    -- Méthode pour mettre à jour le mixer (à appeler dans update)
  function myMM.update()
    -- Parcours toutes les musiques pour s'assurer
    -- 1) que la musique en cours à son volume à 1, sinon on l'augmente
    -- 2) que si une ancienne musique n'a pas son volume à 0, on le baisse
    for index, music in ipairs(myMM.lstMusics) do
      if index == myMM.currentMusic then
        if music.source:getVolume() < 1 then
          music.source:setVolume(music.source:getVolume()+0.01)
        end
      else
        if music.source:getVolume() > 0 then
          music.source:setVolume(music.source:getVolume()-0.01)
        end
      end
    end
  end

  -- Méthode pour démarrer une musique de la liste (par son ID)
  function myMM.PlayMusic(pNum)
    -- Récupère la musique dans la liste et la démarre
    local music = myMM.lstMusics[pNum]
    if music.source:getVolume() == 0 and myMM.currentMusic ~= pNum then
      print("Start music "..pNum)
      music.source:play()
    end
    -- Prend note de la nouvelle musique
    -- Pour que la méthod update prenne le relai
    myMM.currentMusic = pNum
  end

  return myMM
end

-------------------------------- LOADER ------------------------------------------------------

function love.load()

  -- Passe en 512x256 doublé
  love.window.setMode(1024,512)
  love.window.setTitle(" FLEE ")
  screenw = love.graphics.getWidth()/2
  screenh = love.graphics.getHeight()/2

  -- Crée le héro et le positionne au 1er quart de l'écran, au sol
  hero = CreateHero()
  hero.x = SCREEN_WEIGHT/4
  groundPosition = love.graphics.getHeight() - 10
  hero.y = groundPosition

    -- Crée le MusicManager et lui ajoute 2 musique
  musicManager = CreateMusicManager()
  musicManager.addMusic(musicCool)
  musicManager.addMusic(musicTechno)
  -- Démarre la 1ère musique
  musicManager.PlayMusic(1)

end

--------------------------- UPDATE MANAGER ---------------------------------------------------

function love.update(dt)
  if ecran_courant == "Jeu" then
    updateJeu(dt)
  elseif ecran_courant == "Menu" then
    updateMenu()
  elseif ecran_courant == "Game Over" then
    updateGameOver()
  end
end

--------------------------------- DRAW -------------------------------------------------------

function love.draw()
  if ecran_courant == "Jeu" then
    drawJeu()
  elseif ecran_courant == "Menu" then
    drawMenu()
  elseif ecran_courant == "Game Over" then
    drawGameOver()
  end
end

-------------------------------- FUNCTION ----------------------------------------------------

function love.keypressed(key)
  
  -- Réaction si flèche haut ou espace (+compatibilité Love 0.9)
  if (key == "up" or key == "space") and hero.jump == false then
    -- On note qu'il saute
    hero.jump = true
    -- Il part vers le haut comme une fusée !
    hero.velocityVertical = -400
    -- On joue un effet sonore
    sndJump:play()
  end
  
end

-- function update ecran

function updateJeu(dt)
  
  compteur = compteur + 1 
   -- Déplacement horizontal du héro

   if love.keyboard.isDown("right") then
    hero.x = hero.x + 2 * 60 * dt

  elseif love.keyboard.isDown("left") then
    hero.x = hero.x - 2 * 60 * dt
  end

  -- Applique la vélocité verticale (pour le saut)
  hero.y = hero.y + hero.velocityVertical*dt

  -- Stoppe le héro au sol si il est tombé plus bas que la ligne de sol
  if hero.jump == true and hero.y > groundPosition then
    -- On le cale au sol
    hero.y = groundPosition
    -- On note qu'il ne saute plus et qu'il n'a plus de vélocité verticale
    hero.jump = false
    hero.velocityVertical = 0
    -- On joue un effet sonore
    sndLanding:play()
  end
  -- Applique la gravité
  if hero.jump then
    hero.velocityVertical = hero.velocityVertical + 600*dt
  end

    -- Détermine si on active le scrolling ou pas
  local dif =  hero.x - camera.x
  print(dif)
  print("dif \n")
  print(hero.x)
  print("hero.x\n")
  print(camera.x)
  print("camera.x\n")
  if hero.x >= (screenw-70) then
    camera.x=camera.x + 2 * 60 * dt
    hero.x = hero.x - 2 * 60 * dt

  end
  if hero.x <= 70 then
    if(camera.x>0) then
    camera.x = camera.x - 2* 60 * dt
    end
    hero.x = hero.x + 2 * 60 * dt
  end


  -- Animation du héro, on augmente lentement le numéro de la frame courante
  hero.currentImage = hero.currentImage + 12*dt
  -- Si on a dépassé la dernière frame, on repart de 0
  if hero.currentImage > #hero.listeImagesAnim then
    hero.currentImage = 1
  end

                      ------------- UPDATE Music ---------------
  -- Détermine quelle musique jouer
  if hero.x < screenw/2 and musicManager.currentMusic ~= 1 then
    musicManager.PlayMusic(1)
  elseif hero.x >= screenw/2 and musicManager.currentMusic ~= 2 then
    musicManager.PlayMusic(2)
  end
                      ----------------------------------------


  -- On demande au MusicManager de se mettre à jour
  musicManager.update()

  -- Scrolling infini du fond
  bgX = bgX - (1/10)*dt
  if bgX <= 0-BGImageSize:getWidth() then
    bgX = 1
  end

  bgX_1 = bgX_1 - 15*dt
  if bgX_1 <= 0-BGImageSize:getWidth() then
    bgX_1 = 1
  end

  bgX_2 = bgX_2 - 20*dt
  if bgX_2 <= 0-BGImageSize:getWidth() then
    bgX_2 = 1
  end

  bgX_3 = bgX_3 - 30*dt
  if bgX_3 <= 0-BGImageSize:getWidth() then
    bgX_3 = 1
  end

  bgX_4 = bgX_4 - (85/2)*dt
  if bgX_4 <= 0-BGImageSize:getWidth() then
    bgX_4 = 1
  end

  bgX_5 = bgX_5 - 50*dt
  if bgX_5 <= 0-BGImageSize:getWidth() then
    bgX_5 = 1
  end

  bgX_6 = bgX_6 - 60*dt
  if bgX_6 <= 0-BGImageSize:getWidth() then
    bgX_6 = 1
  end

  bgX_7 = bgX_7 - 70*dt
  if bgX_7 <= 0 - BGImageSize:getWidth() then
    bgX_7 = 1
  end

  bgX_8 = bgX_8 - 80*dt
  if bgX_8 <= 0-BGImageSize:getWidth() then
    bgX_8 = 1
  end

  bgX_9 = bgX_9 - 90*dt
  if bgX_9 <= 0-BGImageSize:getWidth() then
    bgX_9 = 1
  end

end

function updateMenu(dt)
  if love.keyboard.isDown('e') then
    ecran_courant = "Jeu"
  end
end

function updateGameOver(dt)
  if love.keyboard.isDown("E") then
    ecran_courant = "Jeu"
  end
end

function updateEnd(dt)
  if love.keyboard.isDown("E") then
    ecran_courant = "Jeu"
  end
end

-- function draw ecran

function drawJeu()
  -- On sauvegarde les paramètres d'affichage
  love.graphics.push()
  -- On double les pixels
  love.graphics.scale(1,1)

  if compteur < 1000 then
    imgBG = imgBGVilleOcean_0;  
    love.graphics.draw(imgBG,bgX,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX < 1 then
        love.graphics.draw(imgBG,bgX + BGImageSize:getWidth(),1)
      end
    imgBG=imgBGVilleOcean_1;
    love.graphics.draw(imgBG,bgX_1,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_1 < 1 then
        love.graphics.draw(imgBG,bgX_1 + BGImageSize:getWidth(),1)
      end
    imgBG=imgBGVilleOcean_2;
    love.graphics.draw(imgBG,bgX_2,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_2 < 1 then
        love.graphics.draw(imgBG,bgX_2 + BGImageSize:getWidth(),1)
      end
      
    imgBG=imgBGVilleOcean_3;
    love.graphics.draw(imgBG,bgX_3,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_3 < 1 then
        love.graphics.draw(imgBG,bgX_3 + BGImageSize:getWidth(),1)
      end
      
    imgBG=imgBGVilleOcean_4;
    love.graphics.draw(imgBG,bgX_4,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_4 < 1 then
        love.graphics.draw(imgBG,bgX_4 + BGImageSize:getWidth(),1)
      end
      
    imgBG=imgBGVilleOcean_5;
    love.graphics.draw(imgBG,bgX_5,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_5 < 1 then
        love.graphics.draw(imgBG,bgX_5 + BGImageSize:getWidth(),1)
      end
      
    imgBG=imgBGVilleOcean_6;
    love.graphics.draw(imgBG,bgX_6,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_6 < 1 then
        love.graphics.draw(imgBG,bgX_6 + BGImageSize:getWidth(),1)
      end  
      
    imgBG=imgBGVilleOcean_7;
    love.graphics.draw(imgBG,bgX_7,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_7 < 1 then
        love.graphics.draw(imgBG,bgX_7 + BGImageSize:getWidth(),1)
      end 
      
    imgBG=imgBGVilleOcean_8;
    love.graphics.draw(imgBG,bgX_8,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_8 < 1 then
        love.graphics.draw(imgBG,bgX_8 + BGImageSize:getWidth(),1)
      end 
      
    imgBG=imgBGVilleOcean_9;
    love.graphics.draw(imgBG,bgX_9,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_9 < 1 then
        love.graphics.draw(imgBG,bgX_9 + BGImageSize:getWidth(),1)
      end
    
  else
      
      imgBG=imgBGVillejour_fond;  
    love.graphics.draw(imgBG,bgX,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX < 1 then
        love.graphics.draw(imgBG,bgX + BGImageSize:getWidth(),1)
      end
    imgBG=imgBGVillejour_l1;
    love.graphics.draw(imgBG,bgX_1,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_1 < 1 then
        love.graphics.draw(imgBG,bgX_1 + BGImageSize:getWidth(),1)
      end
    imgBG=imgBGVillejour_l2;
    love.graphics.draw(imgBG,bgX_2,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_2 < 1 then
        love.graphics.draw(imgBG,bgX_2 + BGImageSize:getWidth(),1)
      end
      
    imgBG=imgBGVillejour_l3;
    love.graphics.draw(imgBG,bgX_3,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_3 < 1 then
        love.graphics.draw(imgBG,bgX_3 + BGImageSize:getWidth(),1)
      end
      
    imgBG=imgBGVillejour_l4;
    love.graphics.draw(imgBG,bgX_4,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_4 < 1 then
        love.graphics.draw(imgBG,bgX_4 + BGImageSize:getWidth(),1)
      end
      
    imgBG=imgBGVillejour_l5;
    love.graphics.draw(imgBG,bgX_5,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_5 < 1 then
        love.graphics.draw(imgBG,bgX_5 + BGImageSize:getWidth(),1)
      end
      
    imgBG=imgBGVillejour_l6;
    love.graphics.draw(imgBG,bgX_6,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_6 < 1 then
        love.graphics.draw(imgBG,bgX_6 + BGImageSize:getWidth(),1)
      end  
      
    imgBG=imgBGVillejour_train;
    love.graphics.draw(imgBG,bgX_7,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_7 < 1 then
        love.graphics.draw(imgBG,bgX_7 + BGImageSize:getWidth(),1)
      end 
      
    imgBG=imgBGVillejour_l8;
    love.graphics.draw(imgBG,bgX_8,1)
      -- Si il y a du noir à droite, on dessine un 2ème fond
      if bgX_8 < 1 then
        love.graphics.draw(imgBG,bgX_8 + BGImageSize:getWidth(),1)
      end 
    end
    
    -- Dessine le hero en prenant la valeur entière de son numéro de frame
    local nImage = math.floor(hero.currentImage)
    love.graphics.draw(hero.listeImagesAnim[nImage], hero.x - hero.width/2, hero.y - hero.height/2)
    
    -- Texte des noms de zones
    --love.graphics.setColor(255,255,255) -- Pour Love inférieur à 11.0
    love.graphics.setColor(1,1,1) -- Pour Love 11.0 et supérieur  
    love.graphics.print(compteur, screenw/4, 10)

    -- On restaure les paramètres d'affichage
    love.graphics.pop()
end

function drawMenu()
  -- On sauvegarde les paramètres d'affichage
  love.graphics.push()
  -- On double les pixels
  love.graphics.scale(1,1)
  love.graphics.draw(imgMenu)
  love.graphics.pop()
end

function drawGameOver()
  -- On sauvegarde les paramètres d'affichage
  love.graphics.push()
  -- On double les pixels
  love.graphics.scale(1,1)
  love.graphics.draw(imgGameOver)
  love.graphics.pop()
end

function drawEnd()
    -- On sauvegarde les paramètres d'affichage
    love.graphics.push()
    -- On double les pixels
    love.graphics.scale(1,1)
    love.graphics.draw(imgEnd)
    love.graphics.pop()
end

-- function collide

function collide(personnage, obstacle)
  if (a1 == a2) then return false end
  local dx = a1.x - a2.x 
  local dy = a1.y - a2.y
  if (math.abs(dx) < a1.image:getWidth() + a2.image:getWidth()) then
    if (math.abs(dy) < a1.image:getHeight() + a2.image:getHeight()) then
      return true
    end
  end
  return false
end