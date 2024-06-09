using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class OutputInfo : MonoBehaviour
{
    public Transform canvasTransform;
    public Camera mainCamera;
    public AudioProcessor audio;
    public TextMeshProUGUI infoText;
   
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        infoText.text = mainCamera.transform.position.ToString() + "\n" + mainCamera.transform.rotation.eulerAngles.ToString() + "\n" + audio.AudioVolume.ToString();
        canvasTransform.position = mainCamera.transform.TransformPoint(Vector3.forward * 1);
    }
}
