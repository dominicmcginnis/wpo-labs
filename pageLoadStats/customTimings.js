StubHubCustomLoadTiming = window.StubHubCustomLoadTiming || {};

//Data for ads timings
StubHubCustomLoadTiming.adTimings = {
    //Should be set when ads are started (instantiated)
    "adLoadSartTime" : '',
    "contentDisplayTimings" : {}
}

StubHubCustomLoadTiming.createAdTimingsObject = function(slotRenderTime, contentStartTime, contentLoadTime) {
    var timingObj = {
        "slotRenderTime" : slotRenderTime,
        "contentLoadStartTime" : contentStartTime,
        "contentLoadTime" : contentLoadTime
    }
    return timingObj;
};

StubHubCustomLoadTiming.uxLoadTime;

StubHubCustomLoadTiming.getPerformanceResourceTiming = function(resName) {
    var array = performance.getEntries();

    for(var i =0; i < array.length; i++) {
        var timingObj = array[i];
        if(timingObj.name.indexOf(resName) > 0) {
            console.log("Found resource: " + timingObj.name);
            return timingObj;
        }
    }
    return undefined;
}; 

StubHubCustomLoadTiming.setUxLoadTimeFromResource = function(resource) {
    var uxTargetPerformanceResourceTiming = StubHubCustomLoadTiming.getPerformanceResourceTiming(resource);
    StubHubCustomLoadTiming.uxLoadTime = (uxTargetPerformanceResourceTiming) ? uxTargetPerformanceResourceTiming.responseEnd : undefined;
    console.log("Perceived user performance time: " + StubHubCustomLoadTiming.uxLoadTime);
};

StubHubCustomLoadTiming.setUxLoadTimeFromElement = function(element) {
    $(element).livequery(function () {
        var now = new Date().getTime();
        StubHubCustomLoadTiming.uxLoadTime = now - performance.timing.navigationStart;
        console.log("New uxTimer: " + StubHubCustomLoadTiming.uxLoadTime);
    });
};

StubHubCustomLoadTiming.setContentDisplayTimings = function(adSlotId, timing, timeValue) {
    var myTimings = StubHubCustomLoadTiming.adTimings.contentDisplayTimings[adSlotId.getId()]; 
    if(myTimings) {
        if(timing == 'contentLoadTime') {
            timeValue = new Date().getTime() - myTimings.contentLoadStartTime;
        }
        if(timeValue)
            myTimings[timing] = timeValue;
    } else {
        myTimings = StubHubCustomLoadTiming.createAdTimingsObject('', '', '');
        if(timeValue)
            myTimings[timing] = timeValue;                
    }
    StubHubCustomLoadTiming.adTimings.contentDisplayTimings[adSlotId.getId()] =  myTimings;
};

StubHubCustomLoadTiming.setAdUnitContentDisplayLoadTime = function(adSlotId) {
    //Set a callback for when the AdSlot's Iframe is starting to render
    //Note: DFP adds two iframes, one for calling scripts and one for displaying the ad. we want the one that is not hidden            
    $("#"+adSlotId.getDomId()).find("iframe:not([id*=hidden])").livequery(function(){  
        //Establish and log our ad iframe display start time

        StubHubCustomLoadTiming.setContentDisplayTimings(adSlotId, 'contentLoadStartTime', new Date().getTime());              
        //setup our onload handler    
        $("#"+adSlotId.getDomId()).find("iframe:not([id*=hidden])").load(function(){
            //Tell the helper to calculate our ad display time for contentLoadTime
            StubHubCustomLoadTiming.setContentDisplayTimings(adSlotId, 'contentLoadTime');              

            console.log("Ad Content display time for: " + adSlotId.getId() + " - " + StubHubCustomLoadTiming.adTimings.contentDisplayTimings[adSlotId.getId()].contentLoadTime);
        });
    });   
};

StubHubCustomLoadTiming.setAdUnitSlotRenderTime = function(adSlotId) {
    var now = new Date().getTime();
    var slotRenderedTime = now - StubHubCustomLoadTiming.adTimings.adLoadSartTime;

    StubHubCustomLoadTiming.setContentDisplayTimings(adSlotId, 'slotRenderTime', slotRenderedTime); 
    console.log("Ad Slot Render Time for " + adSlotId.getId() + ": " + slotRenderedTime);
};
