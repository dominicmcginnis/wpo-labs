define('common-sh-custom-load-timing', [
], function() {
    'use strict';
    SHCustomLoadTiming = window.SHCustomLoadTiming || {};

    //Data for ads timings
    SHCustomLoadTiming.adTimings = {
        //Should be set when ads are started (instantiated)
        'adLoadSartTime' : '',
        'contentDisplayTimings' : {}
    };

    SHCustomLoadTiming.uxLoadTime;

    SHCustomLoadTiming.measures = [];

    SHCustomLoadTiming.setAdsLoadStartTime = function(time) {
        SHCustomLoadTiming.adTimings.adLoadSartTime = time;
        SHCustomLoadTiming.setPerformanceUserTimeMark('ad-load-start-time');
    };

    SHCustomLoadTiming.createAdTimingsObject = function(slotRenderTime, contentStartTime, contentLoadTime) {
        var timingObj = {
            'slotRenderTime' : slotRenderTime,
            'contentLoadStartTime' : contentStartTime,
            'contentLoadTime' : contentLoadTime
        };
        return timingObj;
    };

    SHCustomLoadTiming.getPerformanceResourceTiming = function(resName) {
        var array = performance.getEntries();

        for (var i = 0; i < array.length; i++) {
            var timingObj = array[i];
            if (timingObj.name.indexOf(resName) > 0) {
                console.debug('Found resource: ' + timingObj.name);
                return timingObj;
            }
        }
        return undefined;
    };

    SHCustomLoadTiming.setUxLoadTimeToNow = function() {
        var now = new Date().getTime();
        SHCustomLoadTiming.uxLoadTime = now - performance.timing.navigationStart;

        SHCustomLoadTiming.setPerformanceUserTimeMark('user-ready');
        SHCustomLoadTiming.setPerformanceUserTimeMeasure('user-ready', 'navigationStart');

        console.debug('SHCustomLoadTiming: New uxTimer: ' + SHCustomLoadTiming.uxLoadTime);
    };

    SHCustomLoadTiming.setUxLoadTimeFromResource = function(resource) {
        var uxTargetPerformanceResourceTiming = SHCustomLoadTiming.getPerformanceResourceTiming(resource);
        SHCustomLoadTiming.uxLoadTime = (uxTargetPerformanceResourceTiming) ? uxTargetPerformanceResourceTiming.responseEnd : undefined;

        if (uxTargetPerformanceResourceTiming) {
            SHCustomLoadTiming.setPerformanceUserTimeMark('user-ready');
            SHCustomLoadTiming.setPerformanceUserTimeMeasure('user-ready', uxTargetPerformanceResourceTiming.responseEnd);
        }

        console.debug('SHCustomLoadTiming: Perceived user performance time: ' + SHCustomLoadTiming.uxLoadTime);
    };

    SHCustomLoadTiming.setUxLoadTimeFromElement = function(element) {
        $(element).livequery(function() {
            var now = new Date().getTime();
            SHCustomLoadTiming.uxLoadTime = now - performance.timing.navigationStart;

            SHCustomLoadTiming.setPerformanceUserTimeMark('user-ready');
            SHCustomLoadTiming.setPerformanceUserTimeMeasure('user-ready', 'navigationStart');

            console.debug('SHCustomLoadTiming: New uxTimer: ' + SHCustomLoadTiming.uxLoadTime);
        });
    };

    SHCustomLoadTiming.setContentDisplayTimings = function(adSlotId, timing, timeValue) {
        var myTimings = SHCustomLoadTiming.adTimings.contentDisplayTimings[adSlotId.getId()];
        if (myTimings) {
            if (timing == 'contentLoadTime') {
                timeValue = new Date().getTime() - myTimings.contentLoadStartTime;
            }
            if (timeValue)
                myTimings[timing] = timeValue;
        } else {
            myTimings = SHCustomLoadTiming.createAdTimingsObject('', '', '');
            if (timeValue)
                myTimings[timing] = timeValue;
        }
        SHCustomLoadTiming.adTimings.contentDisplayTimings[adSlotId.getId()] = myTimings;
    };

    SHCustomLoadTiming.setAdUnitContentDisplayLoadTime = function(adSlotId) {
        //Set a callback for when the AdSlot's Iframe is starting to render
        //Note: DFP adds two iframes, one for calling scripts and one for displaying the ad. we want the one that is not hidden
        $('#'+ adSlotId.getDomId()).find('iframe:not([id*=hidden])').livequery(function() {
            //Establish and log our ad iframe display start time

            SHCustomLoadTiming.setContentDisplayTimings(adSlotId, 'contentLoadStartTime', new Date().getTime());

            SHCustomLoadTiming.setPerformanceUserTimeMark(adSlotId + '-content-load-start');
            //setup our onload handler
            $('#'+ adSlotId.getDomId()).find('iframe:not([id*=hidden])').load(function() {
                //Tell the helper to calculate our ad display time for contentLoadTime
                SHCustomLoadTiming.setContentDisplayTimings(adSlotId, 'contentLoadTime');

                SHCustomLoadTiming.setPerformanceUserTimeMark(adSlotId + '-content-load-time');
                SHCustomLoadTiming.setPerformanceUserTimeMeasure(adSlotId + '-content-load-time', 'mark-' + adSlotId + '-content-load-start');

                console.debug('SHCustomLoadTiming: Ad Content display time for: ' + adSlotId.getId() + ' - ' + SHCustomLoadTiming.adTimings.contentDisplayTimings[adSlotId.getId()].contentLoadTime);
            });
        });
    };

    SHCustomLoadTiming.setAdUnitSlotRenderTime = function(adSlotId) {
        var now = new Date().getTime();
        var slotRenderedTime = now - SHCustomLoadTiming.adTimings.adLoadSartTime;

        SHCustomLoadTiming.setContentDisplayTimings(adSlotId, 'slotRenderTime', slotRenderedTime);

        SHCustomLoadTiming.setPerformanceUserTimeMark(adSlotId + '-slot-render-time');
        SHCustomLoadTiming.setPerformanceUserTimeMeasure(adSlotId + '-slot-render-time', 'mark-ad-load-start-time');

        console.debug('SHCustomLoadTiming: Ad Slot Render Time for ' + adSlotId.getId() + ': ' + slotRenderedTime);
    };

    SHCustomLoadTiming.setPerformanceUserTimeMark = function(name) {
        //Clear previous marks inbound mark
        var markName = 'mark-' + name;
        window.performance.clearMarks(markName);

        //create the new marks
        window.performance.mark(markName);
    };

    SHCustomLoadTiming.setPerformanceUserTimeMeasure = function(name, startMark) {
        //Clear previous measures for inbound mark
        var markName = 'mark-' + name;
        var measureName = 'measure-' + name;
        window.performance.clearMeasures(measureName);

        //create the new measures
        window.performance.measure(measureName, startMark, markName);

        //Track custom SH measurements
        if (SHCustomLoadTiming.measures.indexOf(name) < 0) {
            SHCustomLoadTiming.measures.push(name);
        }
    };

    SHCustomLoadTiming.getPerformanceMeasureTime = function(name) {
        //Clear previous measures for inbound mark
        var measureName = 'measure-' + name;
        var measure = window.performance.getEntriesByName(measureName);

        console.debug('Perf Time for: ' + name + ': ' + measure[0].duration);

        return measure[0].duration;
    };

    SHCustomLoadTiming.getAllPerformanceMeasureTimes = function() {
        var measureObjects = [];
        for (var i = 0; i < SHCustomLoadTiming.measures.length; i++) {
            SHCustomLoadTiming.getPerformanceMeasureTime(SHCustomLoadTiming.measures[i]);
        }
    };

    return SHCustomLoadTiming;

});
