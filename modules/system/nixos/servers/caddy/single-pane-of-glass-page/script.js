document.addEventListener("DOMContentLoaded", function () {
    const tabs = document.querySelectorAll(".tabs span");
    const contents = document.querySelectorAll(".tab-content");

    function activateTab(tab) {
        tabs.forEach(t => t.classList.remove("active"));
        contents.forEach(c => c.classList.remove("active"));

        tab.classList.add("active");
        const contentToShow = document.querySelector('#' + tab.getAttribute("data-target"));
        contentToShow.classList.add("active");

        window.location.hash = tab.getAttribute("data-target").replace("content-", "");
    }

    tabs.forEach(tab => {
        tab.addEventListener("click", function () {
            activateTab(tab);
        });
    });

    if (window.location.hash) {
        const tab = document.querySelector(`span[data-target=content-${window.location.hash.substring(1)}]`)
        if (tab) {
            activateTab(tab);
        }
    } else {
        activateTab(document.querySelector(".tabs .initial-active"));
    }
});