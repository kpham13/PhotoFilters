//
//  CoreDataSeeder.swift
//  PhotoFilters
//
//  Created by Kevin Pham on 10/14/14.
//  Copyright (c) 2014 Kevin Pham. All rights reserved.
//

import Foundation
import CoreData

class CoreDataSeeder {
    
    var managedObjectContext : NSManagedObjectContext!
    
    init(context : NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    func seedCoreData() {
        var sepia = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        sepia.name = "CISepiaTone"
        
        var gaussianBlur = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        gaussianBlur.name = "CIGaussianBlur"
        //gaussianBlur.favorite = true
        
        var pixellate = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        pixellate.name = "CIPixellate"
        
        var gammaAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        gammaAdjust.name = "CIGammaAdjust"
        
        var exposureAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        exposureAdjust.name = "CIExposureAdjust"
        
        var photoEffectChrome = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectChrome.name = "CIPhotoEffectChrome"
        
        var photoEffectInstant = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectInstant.name = "CIPhotoEffectInstant"
        
        var photoEffectMono = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectMono.name = "CIPhotoEffectMono"
        
        var photoEffectNoir = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectNoir.name = "CIPhotoEffectNoir"
        
        var photoEffectTonal = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectTonal.name = "CIPhotoEffectTonal"
        
        var photoEffectTransfer = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectTransfer.name = "CIPhotoEffectTransfer"
        
        /*
        
        CIBlendWithAlphaMask
        CIBlendWithMask
        CIBloom
        CIComicEffect
        CIConvolution3X3
        CIConvolution5X5
        CIConvolution7X7
        CIConvolution9Horizontal
        CIConvolution9Vertical
        CICrystallize
        CIDepthOfField
        CIEdges
        CIEdgeWork
        CIGloom
        CIHeightFieldFromMask
        CIHexagonalPixellate
        CIHighlightShadowAdjust
        CILineOverlay
        CIPixellate
        CIPointillize
        CIShadedMaterial
        CISpotColor
        CISpotLight
        
        CIBoxBlur
        CIDiscBlur
        CIMedianFilter
        CIMotionBlur
        CINoiseReduction
        CIZoomBlur
        CIColorClamp
        CIColorControls
        CIColorMatrix
        CIColorPolynomial
        CILinearToSRGBToneCurve
        CISRGBToneCurveToLinear
        CITemperatureAndTint
        CIToneCurve
        CIVibrance
        CIWhitePointAdjust
        CIColorCrossPolynomial
        CIColorCube
        CIColorCubeWithColorSpace
        CIColorInvert
        CIColorMap
        CIColorMonochrome
        CIColorPosterize
        CIFalseColor
        CIMaskToAlpha
        CIMaximumComponent
        CIMinimumComponent
        CIPhotoEffectChrome
        CIPhotoEffectFade
        CIPhotoEffectInstant
        CIPhotoEffectMono
        CIPhotoEffectNoir
        CIPhotoEffectProcess
        CIPhotoEffectTonal
        CIPhotoEffectTransfer
        CISepiaTone
        CIVignette
        CIVignetteEffect
        CIAdditionCompositing
        CIColorBlendMode
        CIColorBurnBlendMode
        CIColorDodgeBlendMode
        CIDarkenBlendMode
        CIDifferenceBlendMode
        CIExclusionBlendMode
        CIHardLightBlendMode
        CIHueBlendMode
        CILightenBlendMode
        CILuminosityBlendMode
        CIMaximumCompositing
        CIMinimumCompositing
        CIMultiplyBlendMode
        CIMultiplyCompositing
        CIOverlayBlendMode
        CISaturationBlendMode
        CIScreenBlendMode
        CISoftLightBlendMode
        CISourceAtopCompositing
        CISourceInCompositing
        CISourceOutCompositing
        CISourceOverCompositing
        CIBumpDistortion
        CIBumpDistortionLinear
        CICircleSplashDistortion
        CICircularWrap
        CIDroste
        CIDisplacementDistortion
        CIGlassDistortion
        CIGlassLozenge
        CIHoleDistortion
        CILightTunnel
        CIPinchDistortion
        CIStretchCrop
        CITorusLensDistortion
        CITwirlDistortion
        CIVortexDistortion
        CICheckerboardGenerator
        CIConstantColorGenerator
        CILenticularHaloGenerator
        CIQRCodeGenerator
        CIRandomGenerator
        CIStarShineGenerator
        CIStripesGenerator
        CISunbeamsGenerator
        CIAffineTransform
        CICrop
        CILanczosScaleTransform
        CIPerspectiveTransform
        CIPerspectiveTransformWithExtent
        CIStraightenFilter
        CIGaussianGradient
        CILinearGradient
        CIRadialGradient
        CISmoothLinearGradient
        CICircularScreen
        CICMYKHalftone
        CIDotScreen
        CIHatchedScreen
        CILineScreen
        */
        
//        var hueAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
//        photoEffectTransfer.name = "CIHueAdjust"
//        
//        var colorMonochrome = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
//        photoEffectTransfer.name = "CIColorMonochrome"
        
        
        var error : NSError?
        self.managedObjectContext?.save(&error)
        
        if error != nil {
            println("Yay!")
        }
    }
}