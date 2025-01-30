return {
    interaction = 'textui', -- 'textui' 'target'
    progressCircle = true, -- If lib progressCircle should be used instead of progressBar
    moneyItem = 'money',
    bottleItem = 'emptywinebottle',
    

    grapePicking = {   
        items = { -- Do not edit unless you have coding knowledge and plan to edit the code yourself to make it work
           'whitegrape', 
           'redgrape'
        },
        pickChance = { -- The amount of something you have a chance of picking. Set max to 1 for one at a time
            min = 1,
            max = 3
        },
        pickLimit = 2, -- Amount of times a vine can be picked before player must move to a new vine
        pickDuration = 3,
        viewDistance = 3.0,
        interactDistance = 2.5,
        skillCheck = {'easy', 'easy', 'medium'},
        animDict = 'missmechanic',
        animClip = 'work_base',
        scenario = false,
        marker = { 
            type = 21, 
            color = {r = 128, g = 69, b = 171, a = 80}
        }, 
        points = {
            vector3(-1873.59, 2100.24, 138.77),
            vector3(-1878.37, 2100.47, 138.89),
            vector3(-1882.11, 2100.52, 139.0),
            vector3(-1886.72, 2100.5, 139.01),
            vector3(-1884.5, 2100.69, 138.83),
            vector3(-1871.85, 2104.4, 137.45),
            vector3(-1874.55, 2104.8, 137.49),
            vector3(-1880.64, 2105.08, 137.71),
            vector3(-1883.75, 2105.34, 137.26),
            vec3(-1862.63, 2097.99, 138.31 ),
            vec3(-1858.20, 2100.04, 137.99 ),
            vec3(-1854.27, 2101.81, 137.84 ),
            vec3(-1851.19, 2103.26, 137.71 ),
            vec3(-1848.36, 2104.62, 137.68 ),
            vec3(-1843.76, 2106.87, 137.38 ),
            vec3(-1839.44, 2108.93, 136.89 ),
            vec3(-1834.89, 2110.86, 136.16 ),
            vec3(-1831.06, 2112.81, 135.17 )
        },
        targetLabel = 'Pick Grapes',
        targetIcon = 'fa-solid fa-seedling'
    },

    grapeProcessing = {
        item = 'grape',
        processDuration = 3, -- Seconds per grape to process
        bottleDuration = 1, -- Seconds per bottle to bottle
        viewDistance = 3.0,
        interactDistance = 2.5,
        grapesPerBottle = 5, -- Grapes needed to make 1 bottle of wine
        scenario = false,
		animDict = 'anim@gangops@facility@servers@bodysearch@',
		animClip = 'player_search',
        blip = {
            coords = vector3(-1924.7266, 2059.4309, 140.8339),    
            shortRange = true,
            sprite = 93, 
            display = 4,
            scale = 0.6, 
            colour = 27, 
            name = 'Vineyard Processing'
        },
        marker = { type = 21, color = {r = 128, g = 69, b = 171, a = 80}}, 
        point = vector3(-1924.7266, 2059.4309, 140.8339),
        entity = {
            model = 'sf_prop_sf_distillery_01a',
            coords = vector4(-1924.9107666016, 2059.0910644531, 139.83160400391, 161.21),              
        },
        targetLabel = 'Process Grapes',
        targetIcon = 'fa-solid fa-seedling'
    },
    


    wineBoss = { 
        viewDistance = 3.0,
        interactDistance = 2.5,
        van = {
            model = `l35`,
            coords = vec4(-1923.9929, 2039.6896, 140.6378, 100.9027)
        },
        ped = {
            model = 's_m_m_strvend_01',
            coords = vector4(-1920.8260, 2039.2144, 139.7358, 301.0147),
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        },
        blip = {
            coords = vector3(-1923.9929, 2039.6896, 140.6378),    
            shortRange = true,
            sprite = 480, 
            display = 4,
            scale = 0.6, 
            colour = 27, 
            name = 'Vineyard Vinnie',
        },
        buyItems = {
            ['redwinebottle'] = {label = 'Red Wine', sale = 100, multiple = true, icon = 'wine-bottle'},
            ['whitewinebottle'] = {label = 'White Wine', sale = 140, multiple = true, icon = 'wine-bottle'}
        },
        emptyBottleCost = 10,
    },


    debug = true
    
}