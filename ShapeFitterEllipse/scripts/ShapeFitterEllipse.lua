
--Start of Global Scope---------------------------------------------------------

print('AppEngine Version: ' .. Engine.getVersion())

local DELAY = 750 -- ms between visualization steps for demonstration purpose

local viewer = View.create()

-- Cyan color scheme for search regions and points
local searchDecoration = View.ShapeDecoration.create():setFillColor(0, 255, 255, 0)
searchDecoration:setLineColor(0, 255, 255):setLineWidth(3):setPointSize(9)

-- Green color scheme for fitted lines and circles using ransac.
local foundDecoration = View.ShapeDecoration.create():setFillColor(0, 255, 0, 40)
foundDecoration:setLineColor(0, 255, 0):setLineWidth(5):setPointSize(9)

-- Red color scheme for outlier points
local outlierDecoration = View.ShapeDecoration.create()
outlierDecoration:setLineColor(255, 0, 0):setPointSize(9)

-- Create shape fitter. Set fit mode to RANSAC to be robust against outliers.
-- Use fewer probes to do a faster fit.
local sf = Image.ShapeFitter.create()
sf:setFitMode('RANSAC')
sf:setProbeCount(40)
sf:setOutlierMargin(15)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

local function main()
  -- List of images to process
  local liveImages = {
    'resources/ellipse01.png',
    'resources/ellipse02.png',
    'resources/ellipse03.png',
    'resources/ellipse04.png'
  }

  -- Setup search region
  local searchArea = Shape.createCircle(Point.create(460, 600), 450)
  local searchAreaInnerRadius = 10

  -- Run ShapeFitter on each image
  for _, filename in ipairs(liveImages) do
    local image = Image.load(filename)

    -- Fit ellipse
    local foundEllipse = sf:fitEllipse(image, searchArea, searchAreaInnerRadius)
    local inliers, outliers = sf:getEdgePoints()

    -- Show fitting results, show only image first.
    viewer:clear()
    viewer:addImage(image)
    viewer:present()
    Script.sleep(DELAY) -- for demonstration purpose only

    -- Draw search region, points and fitted ellipse.
    viewer:addShape(searchArea, searchDecoration)
    viewer:addShape(
      Shape.createCircle(searchArea:getCenterOfGravity(), searchAreaInnerRadius),
      searchDecoration
    )
    viewer:addShape(foundEllipse, foundDecoration)
    viewer:addShape(inliers, searchDecoration)
    viewer:addShape(outliers, outlierDecoration)
    viewer:present()
    Script.sleep(3 * DELAY) -- for demonstration purpose only
  end

  print('App finished.')
end
--The following registration is part of the global scope which runs once after startup
--Registration of the 'main' function to the 'Engine.OnStarted' event
Script.register('Engine.OnStarted', main)

--End of Function and Event Scope--------------------------------------------------
